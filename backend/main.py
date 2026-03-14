"""Nimora Backend - FastAPI entry point."""

import logging
from contextlib import asynccontextmanager
from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from api.routes import router
from config import get_settings

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

settings = get_settings()
local_storage = Path("local_storage")


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    logger.info("Nimora backend starting...")
    logger.info(f"Interleaved model: {settings.interleaved_model}")
    logger.info(f"Text model: {settings.orchestrator_model}")
    local_storage.mkdir(parents=True, exist_ok=True)
    # Mount local storage for serving generated images
    app.mount("/local_storage", StaticFiles(directory="local_storage"), name="local_storage")
    yield
    # Shutdown
    logger.info("Nimora backend shutting down...")


app = FastAPI(
    title="Nimora API",
    description="Interactive AI Storybook for Children",
    version="1.0.0",
    lifespan=lifespan,
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


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=settings.port)
