import io
import json
import logging
import re
import time
from typing import Optional

from google import genai
from google.genai import types
from PIL import Image

from config import get_settings

logger = logging.getLogger(__name__)


class GeminiService:
    """Handles all Gemini API calls for story and image generation."""

    def __init__(self):
        settings = get_settings()
        self.client = genai.Client(api_key=settings.google_api_key)
        self.text_model = settings.orchestrator_model
        # Interleaved model supports both TEXT + IMAGE output in one call
        self.interleaved_model = settings.interleaved_model
        self._discover_models()

    def _discover_models(self):
        """List available models and log them for debugging."""
        try:
            available = []
            for model in self.client.models.list():
                available.append(model.name)

            logger.info(f"Available models ({len(available)} total):")
            for m in sorted(available):
                logger.info(f"  - {m}")

            # Check if configured interleaved model is available
            interleaved_id = f"models/{self.interleaved_model}"
            if interleaved_id not in available:
                logger.warning(f"Configured interleaved model '{self.interleaved_model}' not found.")
                # Try to find a suitable model
                for m in available:
                    if 'flash' in m and 'image' in m:
                        fallback = m.replace('models/', '')
                        logger.info(f"Auto-selected interleaved model: {fallback}")
                        self.interleaved_model = fallback
                        break
            else:
                logger.info(f"Interleaved model confirmed: {self.interleaved_model}")

        except Exception as e:
            logger.warning(f"Model discovery failed: {e}. Using configured defaults.")

    async def generate_scene_interleaved(
        self,
        prompt: str,
        child_photo: Optional[Image.Image] = None,
    ) -> dict:
        """Generate a story scene using interleaved text+image output in a SINGLE Gemini call.

        This uses Gemini's native mixed-output capability: response_modalities=['TEXT', 'IMAGE'].
        The model generates both the story text and the illustration together.

        Returns:
            dict with keys: "text" (str), "image_bytes" (bytes or None)
        """
        contents = [prompt]
        if child_photo is not None:
            contents.append(child_photo)

        max_retries = 3
        for attempt in range(max_retries):
            try:
                logger.info(f"Generating interleaved scene with model: {self.interleaved_model} (attempt {attempt + 1})")
                response = self.client.models.generate_content(
                    model=self.interleaved_model,
                    contents=contents,
                    config=types.GenerateContentConfig(
                        response_modalities=["TEXT", "IMAGE"],
                        safety_settings=[
                            types.SafetySetting(
                                category="HARM_CATEGORY_HARASSMENT",
                                threshold="BLOCK_MEDIUM_AND_ABOVE",
                            ),
                            types.SafetySetting(
                                category="HARM_CATEGORY_HATE_SPEECH",
                                threshold="BLOCK_MEDIUM_AND_ABOVE",
                            ),
                            types.SafetySetting(
                                category="HARM_CATEGORY_SEXUALLY_EXPLICIT",
                                threshold="BLOCK_MEDIUM_AND_ABOVE",
                            ),
                            types.SafetySetting(
                                category="HARM_CATEGORY_DANGEROUS_CONTENT",
                                threshold="BLOCK_MEDIUM_AND_ABOVE",
                            ),
                        ],
                    ),
                )

                text = ""
                image_bytes = None

                if response.candidates:
                    for part in response.candidates[0].content.parts:
                        if part.text:
                            text += part.text
                        elif part.inline_data is not None:
                            image_bytes = part.inline_data.data
                            logger.info(f"Got interleaved image: {len(image_bytes)} bytes")

                text = self._clean_text(text)
                logger.info(f"Interleaved output — text: {len(text)} chars, image: {'yes' if image_bytes else 'no'}")

                if not text:
                    raise Exception("No text in interleaved response")

                if not image_bytes and attempt < max_retries - 1:
                    logger.warning(f"No image in response, retrying...")
                    time.sleep(2)
                    continue

                return {
                    "text": text,
                    "image_bytes": image_bytes,
                }

            except Exception as e:
                logger.warning(f"Interleaved generation attempt {attempt + 1} failed: {e}")
                if attempt < max_retries - 1:
                    wait = 2 ** attempt  # 1s, 2s
                    logger.info(f"Retrying in {wait}s...")
                    time.sleep(wait)
                else:
                    logger.error(f"Interleaved generation failed after {max_retries} attempts")
                    raise

    @staticmethod
    def _clean_text(text: str) -> str:
        """Remove markdown, JSON blocks, action blocks, and other non-story content."""
        text = re.sub(r'\*\*(.+?)\*\*', r'\1', text)
        text = re.sub(r'\*(.+?)\*', r'\1', text)
        text = re.sub(r'^#+\s+', '', text, flags=re.MULTILINE)
        text = re.sub(r'^[\-\*]{3,}\s*$', '', text, flags=re.MULTILINE)
        text = re.sub(r'\{[^}]*"action"[^}]*\}', '', text, flags=re.DOTALL)
        text = re.sub(r'```[\s\S]*?```', '', text)
        text = re.sub(r'\[([^\]]+)\]\([^)]+\)', r'\1', text)
        text = re.sub(r'^.*\(button://[^)]+\).*$', '', text, flags=re.MULTILINE)
        text = re.sub(r'^.*what should.*do next.*$', '', text, flags=re.MULTILINE | re.IGNORECASE)
        text = re.sub(r'^.*what happens next.*$', '', text, flags=re.MULTILINE | re.IGNORECASE)
        text = re.sub(r'^.*Page \d+ of \d+.*$', '', text, flags=re.MULTILINE)
        text = re.sub(r'\n{3,}', '\n\n', text)
        return text.strip()

    async def _generate_text(self, prompt: str) -> str:
        """Generate story text using the text model."""
        try:
            response = self.client.models.generate_content(
                model=self.text_model,
                contents=[prompt],
            )
            text = response.text.strip() if response.text else ""
            if not text:
                raise Exception("Empty text response")
            return text
        except Exception as e:
            logger.error(f"Text generation failed: {e}")
            raise

    async def generate_choices(
        self,
        story_context: str,
        current_scene: str,
        child_age: int,
        page_number: int,
        max_pages: int,
    ) -> list[dict]:
        """Generate 2-3 story choices with FontAwesome icon names."""
        prompt = f"""Based on this children's story scene, generate exactly 3 fun choices for what happens next.
Return ONLY valid JSON, no other text.

Current scene: "{current_scene}"
Child's age: {child_age}
Story page: {page_number} of {max_pages}

Rules:
- Each choice: 3-6 words, starts with action verb
- For each choice, pick a FontAwesome icon name (from Font Awesome 6) that matches the action
- Make choices exciting, age-appropriate, and lead to different directions
- If page {page_number} is close to {max_pages}, choices should start leading toward a conclusion

Return format:
{{"choices": [
  {{"text": "Explore the castle", "icon": "chess-rook"}},
  {{"text": "Befriend the dragon", "icon": "dragon"}},
  {{"text": "Follow the fairy", "icon": "wand-magic-sparkles"}}
]}}

Common FontAwesome 6 icon names you can use:
chess-rook, dragon, wand-magic-sparkles, person-running, leaf, mountain, fire, star, gem, key, map-location-dot, dove, water, shield-halved, eye-slash, comment, handshake, campground, bridge-water, dungeon, sailboat, apple-whole, compass, route, location-arrow, house, car, heart, music, book, feather, hat-wizard, scroll, ghost, paw, fish, tree, cloud, sun, moon, bolt, snowflake, rainbow"""

        for attempt in range(3):
            try:
                response = self.client.models.generate_content(
                    model=self.text_model,
                    contents=[prompt],
                    config=types.GenerateContentConfig(
                        response_mime_type="application/json",
                    ),
                )
                result = json.loads(response.text)
                choices = result.get("choices", [])
                # Handle both old format (list of strings) and new format (list of dicts)
                if choices and isinstance(choices[0], str):
                    return [{"text": c, "icon": "compass"} for c in choices]
                return choices
            except Exception as e:
                logger.warning(f"Choice generation attempt {attempt + 1} failed: {e}")
                if attempt < 2:
                    time.sleep(2)
                else:
                    logger.error(f"Choice generation failed after 3 attempts")
                    return [
                        {"text": "Continue the adventure", "icon": "compass"},
                        {"text": "Try something new", "icon": "star"},
                        {"text": "Find a surprise", "icon": "gem"},
                    ]
