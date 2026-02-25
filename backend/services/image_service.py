import base64
import io
from PIL import Image


class ImageService:
    """Handles image processing for child photos and generated illustrations."""

    @staticmethod
    def process_upload(image_bytes: bytes, max_size: int = 1024) -> Image.Image:
        """Resize and optimize uploaded child photo for Gemini input."""
        image = Image.open(io.BytesIO(image_bytes))
        image = image.convert("RGB")
        image.thumbnail((max_size, max_size), Image.Resampling.LANCZOS)
        return image

    @staticmethod
    def bytes_to_pil(image_bytes: bytes) -> Image.Image:
        """Convert raw bytes to PIL Image."""
        return Image.open(io.BytesIO(image_bytes))

    @staticmethod
    def pil_to_bytes(image: Image.Image, format: str = "PNG") -> bytes:
        """Convert PIL Image to bytes."""
        buffer = io.BytesIO()
        image.save(buffer, format=format)
        return buffer.getvalue()

    @staticmethod
    def base64_to_bytes(b64_string: str) -> bytes:
        """Decode base64 string to bytes."""
        return base64.b64decode(b64_string)

    @staticmethod
    def bytes_to_base64(image_bytes: bytes) -> str:
        """Encode bytes to base64 string."""
        return base64.b64encode(image_bytes).decode("utf-8")
