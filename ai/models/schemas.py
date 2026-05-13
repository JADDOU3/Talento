from pydantic import BaseModel, Field
from typing import Optional
from enum import Enum


# ─────────────────────────────────────────
# Enums
# ─────────────────────────────────────────

class SignalLevel(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"


class CompletionStatus(str, Enum):
    COMPLETED = "completed"
    INCOMPLETE = "incomplete"
    ABANDONED = "abandoned"


class Language(str, Enum):
    ENGLISH = "en"
    ARABIC = "ar"


# ─────────────────────────────────────────
# Input Models
# ─────────────────────────────────────────

class ChildProfile(BaseModel):
    child_id: int
    age: int
    gender: str
    baseline_traits: list[str] = Field(default_factory=list)


class BehavioralSignals(BaseModel):
    """
    Extracted by Spring SignalExtractorService before sending to AI.
    Each field is a normalized signal level derived from raw events.
    """
    hesitation: SignalLevel
    persistence: SignalLevel
    adaptability: SignalLevel
    hint_dependency: SignalLevel
    frustration: SignalLevel
    focus: SignalLevel
    confidence: SignalLevel


class ActivitySummary(BaseModel):
    activity_id: int
    activity_name: str
    activity_type: str
    duration_seconds: int
    completion_status: CompletionStatus
    attempt_count: int
    hints_used: int
    fail_count: int
    rage_quit: bool
    behavioral_signals: BehavioralSignals
    behavioral_observations: list[str] = Field(default_factory=list)


class MindsetScore(BaseModel):
    """
    Represents a single mindset score.
    mindset_name matches the name stored in DB and ChromaDB.
    """
    mindset_name: str
    score: float = Field(ge=0.0, le=1.0)


class PreviousAnalysisSummary(BaseModel):
    """
    The last stored analysis for this child.
    Sent by Spring from the AIReport table.
    Optional — omitted for first-time analysis.
    """
    focus_trend: Optional[str] = None
    confidence_trend: Optional[str] = None
    stress_response_pattern: Optional[str] = None
    learning_behavior_pattern: Optional[str] = None
    mindset_scores: Optional[list[MindsetScore]] = None
    last_updated: Optional[str] = None
    analysis_version: Optional[str] = None


class AnalysisRequest(BaseModel):
    """
    Full payload sent from Spring to POST /analyze/session
    """
    child_profile: ChildProfile
    activity_summary: ActivitySummary
    previous_analysis_summary: Optional[PreviousAnalysisSummary] = None
    parent_note: Optional[str] = None   # voice-to-text or typed input from parent
    response_language: Language = Language.ENGLISH
    analysis_version: str = "v1"


# ─────────────────────────────────────────
# Output Models
# ─────────────────────────────────────────

class InstantAnalysis(BaseModel):
    """
    Analysis of the current session only.
    Shown to the parent as the session report.
    """
    focus_level: float = Field(ge=0.0, le=1.0)
    confidence_level: float = Field(ge=0.0, le=1.0)
    stress_level: float = Field(ge=0.0, le=1.0)
    adaptability: float = Field(ge=0.0, le=1.0)
    decision_making_pattern: str
    behavioral_summary: str   # in the language specified by caller


class UpdatedMemoryState(BaseModel):
    """
    Updated longitudinal profile for the child.
    Stored back in DB by Spring — used as previous_analysis_summary next time.
    """
    focus_trend: str
    confidence_trend: str
    stress_response_pattern: str
    learning_behavior_pattern: str
    recommended_future_observation: str  # in the language specified by caller


class AnalysisResponse(BaseModel):
    """
    Full response returned from FastAPI to Spring.
    """
    instant_analysis: InstantAnalysis
    updated_memory_state: UpdatedMemoryState
    mindset_scores: list[MindsetScore]
    analysis_confidence: float = Field(ge=0.0, le=1.0)
    analysis_version: str


class VoiceResponse(BaseModel):
    text: str