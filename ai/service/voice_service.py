from fastapi import UploadFile

from llm.voice_to_text_client import transcribe_audio
from models.schemas import VoiceResponse

MAX_AUDIO_SIZE = 25 * 1024 * 1024


async def run_transcription(file: UploadFile) -> VoiceResponse:
    content = await file.read()
    if not content:
        raise ValueError("Empty audio file")
    if len(content) > MAX_AUDIO_SIZE:
        raise ValueError("Audio file exceeds 25MB limit")
    text = await transcribe_audio(file.filename or "audio", content)
    return VoiceResponse(text=text)
