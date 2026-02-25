"""FastAPI routes for the Qissati story API."""

import logging
from fastapi import APIRouter, UploadFile, File, Form, HTTPException
from fastapi.responses import FileResponse
from pathlib import Path

from models.schemas import (
    StoryPage,
    StorySession,
    StartStoryResponse,
    ChoiceRequest,
    ContinueStoryResponse,
)
from services.image_service import ImageService
from services.storage_service import StorageService
from story_agent.tools import generate_story_scene, generate_story_choices
from config import get_settings

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/api")

# In-memory session storage (fine for hackathon)
sessions: dict[str, StorySession] = {}


@router.post("/story/start", response_model=StartStoryResponse)
async def start_story(
    child_name: str = Form(...),
    child_age: int = Form(...),
    theme: str = Form("adventure"),
    photo: UploadFile = File(...),
):
    """Start a new interactive story session."""
    settings = get_settings()

    # Read and process photo
    photo_bytes = await photo.read()
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
        max_pages=settings.max_story_pages,
    )

    # Upload child photo to storage
    storage = StorageService(bucket_name=settings.gcs_bucket_name, use_local=True)
    photo_path = StorageService.generate_path(session_id, "child_photo.png")
    child_photo_url = storage.upload_image(
        ImageService.pil_to_bytes(processed_photo), photo_path
    )
    session.child_photo_url = child_photo_url

    # Generate first scene
    scene_result = await generate_story_scene(
        session_id=session_id,
        child_name=child_name,
        child_age=child_age,
        theme=theme,
        page_number=1,
        max_pages=settings.max_story_pages,
        child_photo_base64=photo_base64,
    )

    # Generate choices for first page
    choices_result = await generate_story_choices(
        story_context="",
        current_scene=scene_result["text"],
        child_age=child_age,
        page_number=1,
        max_pages=settings.max_story_pages,
    )

    # Build page
    page = StoryPage(
        page_number=1,
        text=scene_result["text"],
        image_url=scene_result["image_url"],
        choices=choices_result["choices"],
        is_ending=False,
    )

    session.pages.append(page)
    session.current_page = 1
    sessions[session_id] = session

    # Store photo_base64 in a separate dict for reuse in subsequent scenes
    _photo_cache[session_id] = photo_base64

    return StartStoryResponse(session_id=session_id, page=page)


# Cache child photos for reuse across pages (in-memory)
_photo_cache: dict[str, str] = {}


@router.post("/story/{session_id}/choose", response_model=ContinueStoryResponse)
async def make_choice(session_id: str, request: ChoiceRequest):
    """Continue the story based on the user's choice."""
    settings = get_settings()

    session = sessions.get(session_id)
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    if session.is_complete:
        raise HTTPException(status_code=400, detail="Story is already complete")

    # Get the chosen option
    current_page = session.pages[-1]
    if request.choice_index >= len(current_page.choices):
        raise HTTPException(status_code=400, detail="Invalid choice index")

    choice_made = current_page.choices[request.choice_index]
    next_page_number = session.current_page + 1

    # Build story summary from all previous pages
    previous_summary = "\n".join(
        f"Page {p.page_number}: {p.text}" for p in session.pages
    )

    # Get cached child photo
    photo_base64 = _photo_cache.get(session_id, "")

    # Generate next scene
    scene_result = await generate_story_scene(
        session_id=session_id,
        child_name=session.child_name,
        child_age=session.child_age,
        theme=session.theme,
        page_number=next_page_number,
        max_pages=session.max_pages,
        choice_made=choice_made,
        previous_summary=previous_summary,
        child_photo_base64=photo_base64,
    )

    is_ending = scene_result["is_ending"]

    # Generate choices if not the last page
    choices = []
    if not is_ending:
        choices_result = await generate_story_choices(
            story_context=previous_summary,
            current_scene=scene_result["text"],
            child_age=session.child_age,
            page_number=next_page_number,
            max_pages=session.max_pages,
        )
        choices = choices_result["choices"]

    # Build page
    page = StoryPage(
        page_number=next_page_number,
        text=scene_result["text"],
        image_url=scene_result["image_url"],
        choices=choices,
        is_ending=is_ending,
    )

    session.pages.append(page)
    session.current_page = next_page_number
    session.is_complete = is_ending
    sessions[session_id] = session

    return ContinueStoryResponse(page=page, is_complete=is_ending)


@router.get("/story/{session_id}")
async def get_story(session_id: str):
    """Get the complete story so far."""
    session = sessions.get(session_id)
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
    return session


@router.get("/health")
async def health_check():
    """Health check endpoint."""
    return {"status": "healthy", "service": "qissati-backend"}
