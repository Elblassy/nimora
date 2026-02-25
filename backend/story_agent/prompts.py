"""Prompt templates for story generation."""


def build_scene_prompt(
    child_name: str,
    child_age: int,
    page_number: int,
    max_pages: int,
    choice_made: str = "",
    previous_summary: str = "",
    theme: str = "adventure",
) -> str:
    """Build the scene generation prompt for Gemini interleaved output."""

    theme_settings = {
        "adventure": "magical forest with hidden treasures and friendly creatures",
        "space": "colorful outer space with planets, stars, and friendly aliens",
        "ocean": "beautiful underwater world with coral reefs and sea creatures",
        "forest": "enchanted woodland with talking animals and fairy houses",
    }
    theme_desc = theme_settings.get(theme, theme_settings["adventure"])

    is_first_page = page_number == 1
    is_last_page = page_number >= max_pages

    # Build the story context section
    if is_first_page:
        context = f"This is the OPENING page. Set the scene: {child_name} discovers a {theme_desc}."
    else:
        context = f"""STORY SO FAR:
{previous_summary}

THE READER CHOSE: {choice_made}
Continue the story naturally from this choice."""

    # Build ending instruction
    ending = ""
    if is_last_page:
        ending = f"""
ENDING INSTRUCTION: This is the FINAL page (page {page_number} of {max_pages}).
Write a happy, empowering ending. The story concludes with {child_name} feeling proud and special.
End with a warm message like "And {child_name} knew that the greatest adventures were yet to come."
Do NOT mention choices — this is the conclusion."""

    return f"""You are an expert children's book author and illustrator creating page {page_number} of {max_pages} for an interactive story.

CHILD INFO:
- Name: {child_name}
- Age: {child_age} years old
- The attached photo shows what the child looks like — use it as reference for the illustration

{context}

INSTRUCTIONS:
1. Write 2-4 simple, magical sentences continuing the story
2. {child_name} is the hero — make them brave, kind, and clever
3. Keep language appropriate for a {child_age}-year-old
4. Include sensory details (colors, sounds, feelings)
5. Generate a beautiful children's book illustration for this scene

ILLUSTRATION STYLE:
- Warm, colorful children's book illustration
- Whimsical and friendly — NOT scary
- The main character should resemble the child in the reference photo
- Consistent art style: soft watercolor look, bright colors, rounded shapes
- Magical atmosphere with sparkles and warm lighting
{ending}"""
