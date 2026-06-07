from pydantic import BaseModel, Field, ConfigDict
from pydantic.alias_generators import to_camel
from typing import Optional
from enum import Enum


# ─────────────────────────────────────────
# Base — all input models accept camelCase from Spring
# ─────────────────────────────────────────

class CamelModel(BaseModel):
    model_config = ConfigDict(
        alias_generator=to_camel,
        populate_by_name=True,   # also accept snake_case (useful for tests)
    )


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

class ChildProfile(CamelModel):
    child_id: int
    age: int
    gender: str
    baseline_traits: list[str] = Field(default_factory=list)


class BehavioralSignals(CamelModel):
    hesitation: SignalLevel
    persistence: SignalLevel
    adaptability: SignalLevel
    hint_dependency: SignalLevel
    frustration: SignalLevel
    focus: SignalLevel
    confidence: SignalLevel


class ActivitySummary(CamelModel):
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


class SessionAggregate(CamelModel):
    total_sessions: int
    total_activities_attempted: int
    total_duration_seconds: int
    completed_activities: int
    completion_rate: float = Field(ge=0.0, le=1.0)
    total_hints_used: int
    total_fails: int
    total_attempts: int
    rage_quit_count: int
    avg_duration_per_activity_seconds: int


class MindsetScore(CamelModel):
    mindset_name: str
    score: float = Field(ge=0.0, le=1.0)


class PreviousAnalysisSummary(CamelModel):
    focus_trend: Optional[str] = None
    confidence_trend: Optional[str] = None
    stress_response_pattern: Optional[str] = None
    learning_behavior_pattern: Optional[str] = None
    mindset_scores: Optional[list[MindsetScore]] = None
    last_updated: Optional[str] = None
    analysis_version: Optional[str] = None
    context_summary: Optional[str] = None


class AnalysisRequest(CamelModel):
    child_profile: ChildProfile
    session_aggregate: SessionAggregate
    activity_summaries: list[ActivitySummary]
    previous_analysis_summary: Optional[PreviousAnalysisSummary] = None
    parent_note: Optional[str] = None
    response_language: Language = Language.ENGLISH
    analysis_version: str = "v1"


# ─────────────────────────────────────────
# Output Models
# ─────────────────────────────────────────

class InstantAnalysis(BaseModel):
    focus_level: float = Field(ge=0.0, le=1.0)
    confidence_level: float = Field(ge=0.0, le=1.0)
    stress_level: float = Field(ge=0.0, le=1.0)
    adaptability: float = Field(ge=0.0, le=1.0)
    decision_making_pattern: str
    behavioral_summary: str


class UpdatedMemoryState(BaseModel):
    focus_trend: str
    confidence_trend: str
    stress_response_pattern: str
    learning_behavior_pattern: str
    recommended_future_observation: str
    context_summary: str


class AnalysisResponse(BaseModel):
    instant_analysis: InstantAnalysis
    updated_memory_state: UpdatedMemoryState
    mindset_scores: list[MindsetScore]
    analysis_confidence: float = Field(ge=0.0, le=1.0)
    analysis_version: str


class VoiceResponse(BaseModel):
    text: str