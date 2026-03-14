from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    google_api_key: str = ""
    gcs_bucket_name: str = "nimora-stories"
    google_cloud_project: str = "nimora-hackathon"
    google_cloud_location: str = "us-central1"
    frontend_url: str = "http://localhost:8080"
    port: int = 8000

    # Interleaved model (TEXT + IMAGE in single call)
    interleaved_model: str = "gemini-2.5-flash-image"
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
