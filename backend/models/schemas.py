from pydantic import BaseModel, Field
from typing import Optional


class ChildInfo(BaseModel):
    name: str = Field(..., min_length=1, max_length=50)
    age: int = Field(..., ge=3, le=12)
    theme: str = Field(default="adventure")


class StoryPage(BaseModel):
    page_number: int
    text: str
    image_url: str
    choices: list[str] = Field(default_factory=list)
    is_ending: bool = False


class StorySession(BaseModel):
    session_id: str
    child_name: str
    child_age: int
    theme: str
    pages: list[StoryPage] = Field(default_factory=list)
    current_page: int = 0
    max_pages: int = 6
    is_complete: bool = False
    child_photo_url: str = ""


class StartStoryResponse(BaseModel):
    session_id: str
    page: StoryPage


class ChoiceRequest(BaseModel):
    choice_index: int = Field(..., ge=0, le=2)


class ContinueStoryResponse(BaseModel):
    page: StoryPage
    is_complete: bool = False
