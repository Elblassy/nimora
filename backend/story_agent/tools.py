"""ADK tool functions for story generation."""

import logging
from typing import Optional

from services.gemini_service import GeminiService
from services.storage_service import StorageService
from services.image_service import ImageService
from story_agent.prompts import build_scene_prompt
from config import get_settings

logger = logging.getLogger(__name__)

# Module-level singletons (initialized on first use)
_gemini_service: Optional[GeminiService] = None
_storage_service: Optional[StorageService] = None


def _get_gemini() -> GeminiService:
    global _gemini_service
    if _gemini_service is None:
        _gemini_service = GeminiService()
    return _gemini_service


def _get_storage() -> StorageService:
    global _storage_service
    if _storage_service is None:
        settings = get_settings()
        _storage_service = StorageService(
            bucket_name=settings.gcs_bucket_name,
            use_local=not settings.google_api_key or True,  # Default to local for dev
        )
    return _storage_service


async def generate_story_scene(
    session_id: str,
    child_name: str,
    child_age: int,
    theme: str,
    page_number: int,
    max_pages: int,
    choice_made: str = "",
    previous_summary: str = "",
    child_photo_base64: str = "",
) -> dict:
    """Generate a story scene with interleaved text and illustration.

    Args:
        session_id: Unique session identifier
        child_name: The child's first name
        child_age: The child's age in years
        theme: Story theme (adventure/space/ocean/forest)
        page_number: Current page number (1-based)
        max_pages: Total number of pages
        choice_made: The choice the user made leading to this scene
        previous_summary: Summary of the story so far
        child_photo_base64: Base64 encoded child photo

    Returns:
        dict with: text, image_url, is_ending
    """
    gemini = _get_gemini()
    storage = _get_storage()

    # Build prompt
    prompt = build_scene_prompt(
        child_name=child_name,
        child_age=child_age,
        page_number=page_number,
        max_pages=max_pages,
        choice_made=choice_made,
        previous_summary=previous_summary,
        theme=theme,
    )

    # Prepare child photo if available
    child_photo = None
    if child_photo_base64:
        photo_bytes = ImageService.base64_to_bytes(child_photo_base64)
        child_photo = ImageService.process_upload(photo_bytes)

    # Generate scene with interleaved output
    result = await gemini.generate_scene(prompt=prompt, child_photo=child_photo)

    # Upload generated image to storage
    image_url = ""
    if result["image_bytes"]:
        path = StorageService.generate_path(session_id, f"page_{page_number}.png")
        image_url = storage.upload_image(result["image_bytes"], path)

    is_ending = page_number >= max_pages

    return {
        "text": result["text"],
        "image_url": image_url,
        "is_ending": is_ending,
    }


async def generate_story_choices(
    story_context: str,
    current_scene: str,
    child_age: int,
    page_number: int,
    max_pages: int,
) -> dict:
    """Generate 2-3 interactive story choices.

    Args:
        story_context: Full story context so far
        current_scene: The current scene text
        child_age: Child's age for age-appropriate content
        page_number: Current page number
        max_pages: Total pages in story

    Returns:
        dict with: choices (list of strings)
    """
    gemini = _get_gemini()
    choices = await gemini.generate_choices(
        story_context=story_context,
        current_scene=current_scene,
        child_age=child_age,
        page_number=page_number,
        max_pages=max_pages,
    )
    return {"choices": choices}
