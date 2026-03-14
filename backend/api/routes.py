"""FastAPI routes for the Nimora story API."""

import logging
from typing import Optional
from fastapi import APIRouter, UploadFile, File, Form, HTTPException, BackgroundTasks

from models.schemas import (
    StorySession,
    StartStoryResponse,
    ChoiceRequest,
    ContinueStoryResponse,
)
from services.image_service import ImageService
from services.storage_service import StorageService
from services.session_service import session_service
from services.story_orchestrator import story_orchestrator
from story_agent.tools import generate_audio_narration
from config import get_settings

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/api")


async def _generate_audio_background(session_id: str, page_number: int, story_text: str):
    """Generate audio in background and update the session page."""
    try:
        audio_result = await generate_audio_narration(
            session_id=session_id,
            page_number=page_number,
            story_text=story_text,
        )
        audio_url = audio_result.get("audio_url", "")
        if audio_url:
            session_service.update_page_audio(session_id, page_number, audio_url)
    except Exception as e:
        logger.error(f"Background audio generation failed: {e}")



@router.post("/story/start", response_model=StartStoryResponse)
async def start_story(
    background_tasks: BackgroundTasks,
    child_name: str = Form(...),
    child_age: int = Form(...),
    theme: str = Form("forest_journey"),
    style: str = Form("watercolor"),
    photo: Optional[UploadFile] = File(None),
):
    """Start a new interactive story session."""
    settings = get_settings()

    # Read and process photo
    photo_base64 = ""
    if photo is not None:
        photo_bytes = await photo.read()
        if photo_bytes:
            processed_photo = ImageService.process_upload(photo_bytes)
            photo_base64 = ImageService.bytes_to_base64(
                ImageService.pil_to_bytes(processed_photo)
            )

    # Create session
    session_id = StorageService.generate_session_id()
    session = StorySession(
        session_id=session_id,
        child_name=child_name,
        child_age=child_age,
        theme=theme,
        style=style,
        max_pages=settings.max_story_pages,
    )
    session_service.create_session(session)

    # Generate first page + title
    page, story_title = await story_orchestrator.start_story(
        child_name=child_name,
        child_age=child_age,
        theme=theme,
        style=style,
        photo_base64=photo_base64,
        session_id=session_id,
    )

    # Fire audio generation in background
    background_tasks.add_task(
        _generate_audio_background, session_id, 1, page.text
    )

    return StartStoryResponse(session_id=session_id, page=page, story_title=story_title)


@router.post("/story/{session_id}/choose", response_model=ContinueStoryResponse)
async def make_choice(session_id: str, request: ChoiceRequest, background_tasks: BackgroundTasks):
    """Continue the story based on the user's choice."""
    session = session_service.get_session(session_id)
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    if session.is_complete:
        raise HTTPException(status_code=400, detail="Story is already complete")

    current_page = session.pages[-1]
    if request.choice_index >= len(current_page.choices):
        raise HTTPException(status_code=400, detail="Invalid choice index")

    choice_made = current_page.choices[request.choice_index].text

    page = await story_orchestrator.continue_story(session, choice_made)

    # Fire audio generation in background
    background_tasks.add_task(
        _generate_audio_background, session_id, page.page_number, page.text
    )

    return ContinueStoryResponse(page=page, is_complete=session.is_complete)


@router.get("/story/{session_id}/audio/{page_number}")
async def get_audio_url(session_id: str, page_number: int):
    """Poll for audio URL once background generation completes."""
    session = session_service.get_session(session_id)
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    for page in session.pages:
        if page.page_number == page_number:
            return {"audio_url": page.audio_url or ""}

    raise HTTPException(status_code=404, detail="Page not found")


@router.get("/story/{session_id}")
async def get_story(session_id: str):
    """Get the complete story so far."""
    session = session_service.get_session(session_id)
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
    return session


@router.get("/health")
async def health_check():
    """Health check endpoint."""
    return {"status": "healthy", "service": "nimora-backend"}
