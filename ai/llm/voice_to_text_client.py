import io
from typing import Optional
from openai import AsyncOpenAI

from core.config import get_settings

settings = get_settings()
_client: Optional[AsyncOpenAI] = None


def _get_client() -> AsyncOpenAI:
    global _client
    if _client is None:
        _client = AsyncOpenAI(api_key=settings.openai_api_key)
    return _client


async def transcribe_audio(filename: str, content: bytes) -> str:
    client = _get_client()
    audio_file = io.BytesIO(content)
    audio_file.name = filename or "audio"
    response = await client.audio.transcriptions.create(
        model=settings.whisper_model,
        file=audio_file,
    )
    return response.text

