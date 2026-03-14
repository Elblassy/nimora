"""Prompt templates for story generation."""


THEME_SETTINGS = {
    "forest_journey": "magical forest with hidden treasures, ancient trees, and friendly woodland creatures",
    "space_mission": "colorful outer space with planets, stars, rocket ships, and friendly aliens",
    "pirate_island": "tropical pirate island with buried treasure, sandy beaches, and a pirate ship",
    "dinosaur_world": "prehistoric world filled with friendly dinosaurs, volcanoes, and lush jungles",
    "magic_kingdom": "enchanted kingdom with castles, wizards, dragons, and magical spells",
    "ocean_quest": "beautiful underwater world with coral reefs, sea creatures, and sunken ships",
    "desert_treasure": "vast golden desert with ancient pyramids, hidden caves, and magical treasures",
    "castle_mystery": "mysterious medieval castle with secret passages, enchanted rooms, and riddles",
}

STYLE_SETTINGS = {
    "watercolor": "soft watercolor illustration style with gentle brush strokes, flowing colors, and dreamy textures",
    "digital_painting": "polished digital painting style with rich colors, smooth gradients, and detailed lighting",
    "3d": "3D rendered style with soft lighting, rounded characters, and a Pixar-like aesthetic",
    "clay": "claymation/clay art style with textured surfaces, sculpted characters, and a stop-motion feel",
}


def build_character_description_prompt(
    child_name: str,
    child_age: int,
    theme: str = "forest_journey",
) -> str:
    """Build a prompt to generate a fixed character description for the entire story."""
    theme_desc = THEME_SETTINGS.get(theme, THEME_SETTINGS["forest_journey"])
    return f"""Create a short, vivid character description for a children's book character.

The character is {child_name}, a {child_age}-year-old child who is the hero of a {theme_desc} story.

Describe in 2-3 sentences:
1. Their appearance (hair color, skin tone, eye color)
2. Their outfit (specific clothes, colors, accessories they wear throughout the ENTIRE story)
3. One distinctive feature (a hat, a backpack, a scarf, special shoes, etc.)

IMPORTANT: This description will be used for EVERY illustration in the story, so the outfit and features must stay consistent. Pick a fun, adventure-ready outfit.

Return ONLY the character description, nothing else. No markdown, no labels."""


def build_interleaved_prompt(
    child_name: str,
    child_age: int,
    page_number: int,
    max_pages: int,
    choice_made: str = "",
    previous_summary: str = "",
    theme: str = "forest_journey",
    style: str = "watercolor",
    character_description: str = "",
) -> str:
    """Build a single prompt that produces BOTH story text AND illustration (interleaved output)."""
    theme_desc = THEME_SETTINGS.get(theme, THEME_SETTINGS["forest_journey"])
    style_desc = STYLE_SETTINGS.get(style, STYLE_SETTINGS["watercolor"])

    is_first_page = page_number == 1
    is_last_page = page_number >= max_pages

    if is_first_page:
        context = f"This is the OPENING page. Set the scene: {child_name} discovers a {theme_desc}."
    else:
        context = f"""STORY SO FAR:
{previous_summary}

THE READER CHOSE: {choice_made}
Continue the story naturally from this choice."""

    ending = ""
    if is_last_page:
        ending = f"""
ENDING: This is the FINAL page (page {page_number} of {max_pages}). You MUST write a happy, empowering ending that wraps up the entire story.
- Resolve the adventure — the quest is complete, the mystery is solved, the treasure is found
- {child_name} feels proud, brave, and special
- End with a warm closing line like "And {child_name} knew that the greatest adventures were yet to come."
- This is THE END — no cliffhangers, no open threads
"""
    elif page_number == max_pages - 1:
        ending = f"""
PACING: This is page {page_number} of {max_pages} — the SECOND TO LAST page. Start building toward the climax. The adventure should reach its peak moment (the final challenge, the big discovery, the dramatic moment). The NEXT page will be the happy ending, so set it up here.
"""

    character_block = ""
    if character_description:
        character_block = f"""
CHARACTER (MUST match this description exactly in the illustration):
{character_description}
"""
    else:
        character_block = f"\nCharacter: {child_name}, a {child_age}-year-old child.\n"

    return f"""You are an expert children's book creator. Generate page {page_number} of {max_pages} for an interactive story.

You must output BOTH:
1. Story text (2-4 simple, magical sentences)
2. A beautiful illustration matching the scene

CHILD: {child_name}, age {child_age}

{context}

STORY TEXT RULES:
- {child_name} is the hero — brave, kind, and clever
- Age-appropriate language for a {child_age}-year-old
- Include sensory details (colors, sounds, feelings)
- Do NOT include choices, options, or questions
- Output the plain story text first, then generate the illustration
{ending}

ILLUSTRATION RULES:
- Style: {style_desc}
- Colorful children's book illustration, bright colors, rounded shapes
- Magical atmosphere with sparkles and warm lighting
- Whimsical and friendly, NOT scary
{character_block}

Now write the story text for this page, then generate a matching illustration."""


