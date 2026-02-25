import os
import uuid
import logging
from pathlib import Path
from typing import Optional

logger = logging.getLogger(__name__)


class StorageService:
    """Handles file storage - GCS in production, local filesystem for dev."""

    def __init__(self, bucket_name: str, use_local: bool = False):
        self.bucket_name = bucket_name
        self.use_local = use_local
        self._bucket = None
        self._local_dir = Path("local_storage")

        if use_local:
            self._local_dir.mkdir(parents=True, exist_ok=True)
        else:
            try:
                from google.cloud import storage
                client = storage.Client()
                self._bucket = client.bucket(bucket_name)
            except Exception as e:
                logger.warning(f"GCS init failed: {e}. Falling back to local storage.")
                self.use_local = True
                self._local_dir.mkdir(parents=True, exist_ok=True)

    def upload_image(self, image_bytes: bytes, path: str, content_type: str = "image/png") -> str:
        """Upload image and return public URL."""
        if self.use_local:
            return self._upload_local(image_bytes, path)
        return self._upload_gcs(image_bytes, path, content_type)

    def _upload_gcs(self, image_bytes: bytes, path: str, content_type: str) -> str:
        """Upload to Google Cloud Storage."""
        blob = self._bucket.blob(path)
        blob.upload_from_string(image_bytes, content_type=content_type)
        blob.make_public()
        return blob.public_url

    def _upload_local(self, image_bytes: bytes, path: str) -> str:
        """Save to local filesystem for development."""
        file_path = self._local_dir / path
        file_path.parent.mkdir(parents=True, exist_ok=True)
        file_path.write_bytes(image_bytes)
        return f"/local_storage/{path}"

    @staticmethod
    def generate_path(session_id: str, filename: str) -> str:
        """Generate a storage path for a file."""
        return f"stories/{session_id}/{filename}"

    @staticmethod
    def generate_session_id() -> str:
        """Generate a unique session ID."""
        return str(uuid.uuid4())[:8]
