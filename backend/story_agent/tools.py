"""ADK tool functions for story generation."""

import logging
from typing import Optional

from services.gemini_service import GeminiService
from services.storage_service import StorageService
from services.image_service import ImageService
from services.tts_service import TTSService
from story_agent.prompts import build_character_description_prompt, build_interleaved_prompt
from config import get_settings

logger = logging.getLogger(__name__)

# Module-level singletons (initialized on first use)
_gemini_service: Optional[GeminiService] = None
_storage_service: Optional[StorageService] = None
_tts_service: Optional[TTSService] = None


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
            use_local=True,
        )
    return _storage_service


def _get_tts() -> TTSService:
    global _tts_service
    if _tts_service is None:
        _tts_service = TTSService()
    return _tts_service


async def generate_character_description(
    child_name: str,
    child_age: int,
    theme: str,
    child_photo_base64: str = "",
) -> str:
    """Generate a fixed character description to use across all illustrations.

    Args:
        child_name: The child's first name
        child_age: The child's age in years
        theme: Story theme
        child_photo_base64: Base64 encoded child photo (optional)

    Returns:
        Character description string
    """
    gemini = _get_gemini()
    prompt = build_character_description_prompt(
        child_name=child_name,
        child_age=child_age,
        theme=theme,
    )

    # If we have a child photo, include it so the description matches the photo
    contents = [prompt]
    if child_photo_base64:
        photo_bytes = ImageService.base64_to_bytes(child_photo_base64)
        child_photo = ImageService.process_upload(photo_bytes)
        contents.append(child_photo)
        contents[0] = prompt + "\n\nUse the attached photo as reference for the child's appearance."

    try:
        response = gemini.client.models.generate_content(
            model=gemini.text_model,
            contents=contents,
        )
        desc = response.text.strip() if response.text else ""
        desc = gemini._clean_text(desc)
        logger.info(f"Generated character description: {desc[:100]}...")
        return desc
    except Exception as e:
        logger.warning(f"Character description generation failed: {e}")
        return f"{child_name}, a {child_age}-year-old child with bright eyes and a big smile, wearing a colorful adventure outfit with a small backpack."


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
    character_description: str = "",
    style: str = "watercolor",
) -> dict:
    """Generate a story scene with interleaved text and illustration.

    Args:
        session_id: Unique session identifier
        child_name: The child's first name
        child_age: The child's age in years
        theme: Story theme (forest_journey/space_mission/etc.)
        page_number: Current page number (1-based)
        max_pages: Total number of pages
        choice_made: The choice the user made leading to this scene
        previous_summary: Summary of the story so far
        child_photo_base64: Base64 encoded child photo
        character_description: Fixed character description for consistent illustrations

    Returns:
        dict with: text, image_url, is_ending
    """
    gemini = _get_gemini()
    storage = _get_storage()

    # Build single interleaved prompt (text + image in one call)
    prompt = build_interleaved_prompt(
        child_name=child_name,
        child_age=child_age,
        page_number=page_number,
        max_pages=max_pages,
        choice_made=choice_made,
        previous_summary=previous_summary,
        theme=theme,
        style=style,
        character_description=character_description,
    )

    # Prepare child photo if available
    child_photo = None
    if child_photo_base64:
        photo_bytes = ImageService.base64_to_bytes(child_photo_base64)
        child_photo = ImageService.process_upload(photo_bytes)

    # Generate scene using interleaved output (text + image in single Gemini call)
    result = await gemini.generate_scene_interleaved(prompt=prompt, child_photo=child_photo)

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


async def generate_story_title(
    child_name: str,
    theme: str,
    first_page_text: str,
) -> str:
    """Generate a creative story title based on the first page."""
    gemini = _get_gemini()
    prompt = (
        f"Generate a short, creative, magical story title (3-6 words) for a children's story. "
        f"The hero is {child_name}, the theme is {theme.replace('_', ' ')}. "
        f"Here is the first page:\n{first_page_text}\n\n"
        f"Return ONLY the title, no quotes, no explanation."
    )
    try:
        response = gemini.client.models.generate_content(
            model=gemini.text_model,
            contents=[prompt],
        )
        title = response.text.strip().strip('"\'') if response.text else ""
        title = gemini._clean_text(title)
        return title if title else f"{child_name}'s Adventure"
    except Exception as e:
        logger.warning(f"Title generation failed: {e}")
        return f"{child_name}'s Adventure"


async def generate_audio_narration(
    session_id: str,
    page_number: int,
    story_text: str,
) -> dict:
    """Generate audio narration for a story page using text-to-speech.

    Call this AFTER generate_story_scene to create an audio version of the story text.
    The audio file is saved and a URL is returned for playback.

    Args:
        session_id: Unique session identifier
        page_number: Current page number (1-based)
        story_text: The story text to narrate

    Returns:
        dict with: audio_url (string path to WAV file)
    """
    tts = _get_tts()
    audio_url = await tts.generate_narration(
        text=story_text,
        session_id=session_id,
        page_number=page_number,
    )
    return {"audio_url": audio_url}
