"""Qissati Backend - FastAPI entry point."""

import logging
from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from api.routes import router
from config import get_settings

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

settings = get_settings()

app = FastAPI(
    title="Qissati API",
    description="Interactive AI Storybook for Children",
    version="1.0.0",
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API routes
app.include_router(router)

# Serve local storage files in development
local_storage = Path("local_storage")
if local_storage.exists():
    app.mount("/local_storage", StaticFiles(directory="local_storage"), name="local_storage")


@app.on_event("startup")
async def startup():
    logger.info("Qissati backend starting...")
    logger.info(f"Primary image model: {settings.primary_image_model}")
    logger.info(f"Fallback image model: {settings.fallback_image_model}")
    # Ensure local storage dir exists
    local_storage.mkdir(parents=True, exist_ok=True)


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=settings.port)
