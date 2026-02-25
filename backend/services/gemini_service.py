import io
import json
import logging
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
        self.primary_model = settings.primary_image_model
        self.fallback_model = settings.fallback_image_model
        self.orchestrator_model = settings.orchestrator_model

    async def generate_scene(
        self,
        prompt: str,
        child_photo: Optional[Image.Image] = None,
    ) -> dict:
        """Generate a story scene with interleaved text + image.

        Tries primary model first, falls back to secondary.

        Returns:
            dict with keys: "text" (str), "image_bytes" (bytes or None)
        """
        models = [self.primary_model, self.fallback_model]

        contents = [prompt]
        if child_photo is not None:
            contents.append(child_photo)

        for model in models:
            try:
                logger.info(f"Generating scene with model: {model}")
                response = self.client.models.generate_content(
                    model=model,
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
                return self._parse_interleaved_response(response)

            except Exception as e:
                logger.warning(f"Model {model} failed: {e}")
                time.sleep(2)
                continue

        raise Exception("All image models failed to generate scene")

    async def generate_choices(
        self,
        story_context: str,
        current_scene: str,
        child_age: int,
        page_number: int,
        max_pages: int,
    ) -> list[str]:
        """Generate 2-3 story choices using the orchestrator model."""
        prompt = f"""Based on this children's story scene, generate exactly 3 fun choices for what happens next.
Return ONLY valid JSON, no other text.

Current scene: "{current_scene}"
Child's age: {child_age}
Story page: {page_number} of {max_pages}

Rules:
- Each choice: 3-6 words, starts with action verb
- Include a relevant emoji at the start of each choice
- Make choices exciting, age-appropriate, and lead to different directions
- If page {page_number} is close to {max_pages}, choices should start leading toward a conclusion

Return format:
{{"choices": ["🏰 Explore the castle", "🐉 Befriend the dragon", "✨ Follow the fairy"]}}"""

        try:
            response = self.client.models.generate_content(
                model=self.orchestrator_model,
                contents=[prompt],
                config=types.GenerateContentConfig(
                    response_mime_type="application/json",
                ),
            )
            result = json.loads(response.text)
            return result.get("choices", ["✨ Continue the adventure", "🌟 Try something new", "🎯 Find a surprise"])
        except Exception as e:
            logger.error(f"Choice generation failed: {e}")
            return ["✨ Continue the adventure", "🌟 Try something new", "🎯 Find a surprise"]

    def _parse_interleaved_response(self, response) -> dict:
        """Parse Gemini response containing interleaved text and image parts."""
        text_parts = []
        image_bytes = None

        if not response.candidates:
            raise Exception("No candidates in Gemini response")

        for part in response.candidates[0].content.parts:
            if part.text is not None:
                text_parts.append(part.text)
            elif part.inline_data is not None:
                image_bytes = part.inline_data.data

        story_text = " ".join(text_parts).strip()
        if not story_text:
            raise Exception("No text in Gemini response")

        return {
            "text": story_text,
            "image_bytes": image_bytes,
        }
