from fastapi import APIRouter, UploadFile, File, HTTPException
from models.schemas import AnalysisRequest, AnalysisResponse, VoiceResponse
from service.analysis_service import run_analysis_service
from service.voice_service import run_transcription

router = APIRouter()


@router.post("/analyze", response_model=AnalysisResponse)
async def analyze_session(request: AnalysisRequest):
    try:
        return await run_analysis_service(request)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/voice/transcribe", response_model=VoiceResponse)
async def transcribe_voice(file: UploadFile = File(...)):
    if file.content_type not in ["audio/mpeg", "audio/wav", "audio/m4a", "audio/mp4", "audio/webm"]:
        raise HTTPException(status_code=400, detail="Unsupported audio format")
    try:
        return await run_transcription(file)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))