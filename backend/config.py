from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    google_api_key: str = ""
    gcs_bucket_name: str = "qissati-stories"
    google_cloud_project: str = "qissati-hackathon"
    google_cloud_location: str = "us-central1"
    frontend_url: str = "http://localhost:8080"
    port: int = 8000

    # Image generation models (ordered by preference)
    primary_image_model: str = "gemini-2.0-flash-preview-image-generation"
    fallback_image_model: str = "gemini-2.0-flash-preview-image-generation"
    orchestrator_model: str = "gemini-2.5-flash"

    # Story settings
    max_story_pages: int = 6
    num_choices: int = 3

    class Config:
        env_file = ".env"
        extra = "ignore"


@lru_cache()
def get_settings() -> Settings:
    return Settings()
