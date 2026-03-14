from pydantic import BaseModel, Field
from typing import Optional


class ChildInfo(BaseModel):
    name: str = Field(..., min_length=1, max_length=50)
    age: int = Field(..., ge=3, le=12)
    theme: str = Field(default="forest_journey")


class StoryChoice(BaseModel):
    text: str
    icon: str = "compass"


class StoryPage(BaseModel):
    page_number: int
    text: str
    image_url: str
    audio_url: str = ""
    choices: list[StoryChoice] = Field(default_factory=list)
    is_ending: bool = False


class StorySession(BaseModel):
    session_id: str
    child_name: str
    child_age: int
    theme: str
    style: str = "watercolor"
    story_title: str = ""
    pages: list[StoryPage] = Field(default_factory=list)
    current_page: int = 0
    max_pages: int = 6
    is_complete: bool = False


class StartStoryResponse(BaseModel):
    session_id: str
    page: StoryPage
    story_title: str = ""


class ChoiceRequest(BaseModel):
    choice_index: int = Field(..., ge=0, le=5)


class ContinueStoryResponse(BaseModel):
    page: StoryPage
    is_complete: bool = False
