from fastapi import FastAPI
from contextlib import asynccontextmanager
from core.config import get_settings
from route.router import router

settings = get_settings()


@asynccontextmanager
async def lifespan(app: FastAPI):
    print(f"Starting Talento AI Service [{settings.app_env}]")
    print(f"Analysis model : {settings.analysis_model}")
    print(f"Transcription model : {settings.whisper_model}")
    print(f"ChromaDB       : {settings.chroma_host}:{settings.chroma_port}")
    yield
    print("Shutting down Talento AI Service")


app = FastAPI(
    title="Talento AI Service",
    version="1.0.0",
    lifespan=lifespan
)

app.include_router(router)