"""Text-to-Speech service using Gemini TTS."""

import asyncio
import logging
import wave
from functools import partial
from pathlib import Path

from google import genai
from google.genai import types

from config import get_settings

logger = logging.getLogger(__name__)


class TTSService:
    """Generate audio narration using Gemini TTS model."""

    def __init__(self):
        settings = get_settings()
        self.client = genai.Client(api_key=settings.google_api_key)
        self.model = "gemini-2.5-flash-preview-tts"
        self.voice = "Puck"  # Friendly, warm voice for children's stories

    def _generate_sync(self, text: str, session_id: str, page_number: int) -> str:
        """Synchronous TTS call — meant to run in a thread."""
        response = self.client.models.generate_content(
            model=self.model,
            contents=f"Read this children's story page warmly and expressively, as if reading to a child at bedtime: {text}",
            config=types.GenerateContentConfig(
                response_modalities=["AUDIO"],
                speech_config=types.SpeechConfig(
                    voice_config=types.VoiceConfig(
                        prebuilt_voice_config=types.PrebuiltVoiceConfig(
                            voice_name=self.voice,
                        )
                    )
                ),
            ),
        )

        audio_data = response.candidates[0].content.parts[0].inline_data.data

        output_dir = Path("local_storage") / session_id
        output_dir.mkdir(parents=True, exist_ok=True)
        wav_path = output_dir / f"page_{page_number}.wav"
        _save_wav(wav_path, audio_data)

        url = f"/local_storage/{session_id}/page_{page_number}.wav"
        logger.info(f"Generated audio narration: {url} ({len(audio_data)} bytes)")
        return url

    async def generate_narration(
        self,
        text: str,
        session_id: str,
        page_number: int,
    ) -> str:
        """Generate audio narration in a background thread (non-blocking)."""
        try:
            loop = asyncio.get_event_loop()
            return await loop.run_in_executor(
                None, partial(self._generate_sync, text, session_id, page_number)
            )
        except Exception as e:
            logger.error(f"TTS generation failed: {e}")
            return ""


def _save_wav(path: Path, pcm_data: bytes, sample_rate: int = 24000, channels: int = 1, sample_width: int = 2):
    """Save raw PCM audio data as a WAV file."""
    with wave.open(str(path), "wb") as wf:
        wf.setnchannels(channels)
        wf.setsampwidth(sample_width)
        wf.setframerate(sample_rate)
        wf.writeframes(pcm_data)
