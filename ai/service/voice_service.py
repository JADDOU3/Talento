from fastapi import UploadFile

from llm.voice_to_text_client import transcribe_audio
from models.schemas import VoiceResponse


async def run_transcription(file: UploadFile) -> VoiceResponse:
    content = await file.read()
    if not content:
        raise ValueError("Empty audio file")
    text = await transcribe_audio(file.filename or "audio", content)
    return VoiceResponse(text=text)

