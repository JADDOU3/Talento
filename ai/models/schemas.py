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
    hesitation: SignalLevel
    persistence: SignalLevel
    adaptability: SignalLevel
    hint_dependency: SignalLevel
    frustration: SignalLevel
    focus: SignalLevel
    confidence: SignalLevel


class ActivitySummary(BaseModel):
    """
    One entry per unique activity, aggregated across all unanalyzed sessions.
    If the child played the same activity 3 times, this is the merged total.
    """
    activity_id: int
    activity_name: str
    activity_type: str
    duration_seconds: int           # total across all sessions for this activity
    completion_status: CompletionStatus
    attempt_count: int              # total attempts across all sessions
    hints_used: int
    fail_count: int
    rage_quit: bool
    behavioral_signals: BehavioralSignals
    behavioral_observations: list[str] = Field(default_factory=list)


class SessionAggregate(BaseModel):
    """
    Cross-session totals computed by Spring before sending.
    Gives the AI the big picture without raw session data.
    """
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


class MindsetScore(BaseModel):
    mindset_name: str
    score: float = Field(ge=0.0, le=1.0)


class PreviousAnalysisSummary(BaseModel):
    """
    Last stored analysis for this child.
    contextSummary explains WHY the child had those scores —
    gives the AI causal context, not just numbers.
    """
    focus_trend: Optional[str] = None
    confidence_trend: Optional[str] = None
    stress_response_pattern: Optional[str] = None
    learning_behavior_pattern: Optional[str] = None
    mindset_scores: Optional[list[MindsetScore]] = None
    last_updated: Optional[str] = None
    analysis_version: Optional[str] = None
    context_summary: Optional[str] = None


class AnalysisRequest(BaseModel):
    """
    Full payload sent from Spring to POST /analyze
    Contains aggregated data across ALL unanalyzed sessions — not just one.
    """
    child_profile: ChildProfile
    session_aggregate: SessionAggregate
    activity_summaries: list[ActivitySummary]   # one entry per unique activity
    previous_analysis_summary: Optional[PreviousAnalysisSummary] = None
    parent_note: Optional[str] = None
    response_language: Language = Language.ENGLISH
    analysis_version: str = "v1"


# ─────────────────────────────────────────
# Output Models
# ─────────────────────────────────────────

class InstantAnalysis(BaseModel):
    """
    Holistic analysis of everything the child has done since the last report.
    behavioral_summary is the human-readable report shown to the parent.
    """
    focus_level: float = Field(ge=0.0, le=1.0)
    confidence_level: float = Field(ge=0.0, le=1.0)
    stress_level: float = Field(ge=0.0, le=1.0)
    adaptability: float = Field(ge=0.0, le=1.0)
    decision_making_pattern: str
    behavioral_summary: str


class UpdatedMemoryState(BaseModel):
    """
    Updated longitudinal profile.
    context_summary explains WHAT drove these specific scores —
    stored and sent back next time so the AI has narrative continuity.
    """
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