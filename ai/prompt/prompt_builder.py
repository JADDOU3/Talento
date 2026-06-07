import json

from models.schemas import AnalysisRequest, Language

SYSTEM_PROMPT = (
    "You are a behavioral analysis AI specialized in children's cognitive and emotional patterns. "
    "You receive aggregated data from multiple play sessions — not a single session. "
    "Analyze the child's overall behavioral patterns across all activities and produce a holistic report. "
    "Do not make medical diagnoses. Focus on behavioral indicators, emotional responses, "
    "confidence, attention patterns, adaptability, frustration handling, and learning tendencies. "
    "Your context_summary must explain the specific observations that led to your scores — "
    "it will be shown to the AI in the next analysis so it understands the reasoning chain. "
    "Always respond with valid JSON only."
)


def _language_instruction(language: Language) -> str:
    if language == Language.ARABIC:
        return (
            "Write behavioral_summary, recommended_future_observation, and context_summary in Arabic. "
            "Keep all other fields (trend names, pattern names) in English."
        )
    return "Write behavioral_summary, recommended_future_observation, and context_summary in English."


def _format_rag_context(rag: dict) -> str:
    parts = []
    if rag.get("mindsets"):
        parts.append("Mindset definitions:\n" + "\n".join(rag["mindsets"]))
    if rag.get("criteria"):
        parts.append("Criteria and activity links:\n" + "\n".join(rag["criteria"]))
    if rag.get("behavioral_patterns"):
        parts.append("Behavioral patterns:\n" + "\n".join(rag["behavioral_patterns"]))
    if rag.get("interpretation_rules"):
        parts.append("Interpretation rules:\n" + "\n".join(rag["interpretation_rules"]))
    return "\n\n".join(parts).strip()


def build_user_prompt(request: AnalysisRequest, rag: dict) -> str:
    # ── Child profile ────────────────────────────────────────────
    child_section = {
        "age": request.child_profile.age,
        "gender": request.child_profile.gender,
        "baseline_traits": request.child_profile.baseline_traits,
    }

    # ── Session aggregate ────────────────────────────────────────
    aggregate_section = request.session_aggregate.model_dump()

    # ── Activity summaries — compact, one per activity ───────────
    activities_section = [s.model_dump() for s in request.activity_summaries]

    payload = {
        "child_profile": child_section,
        "session_aggregate": aggregate_section,
        "activity_summaries": activities_section,
        "response_language": request.response_language.value,
        "analysis_version": request.analysis_version,
    }

    if request.previous_analysis_summary:
        prev = request.previous_analysis_summary.model_dump(exclude_none=True)
        payload["previous_analysis_summary"] = prev

    if request.parent_note:
        payload["parent_note"] = request.parent_note

    # ── RAG context ──────────────────────────────────────────────
    rag_context = _format_rag_context(rag)

    # ── Output schema ────────────────────────────────────────────
    output_schema = {
        "instant_analysis": {
            "focus_level": 0.0,
            "confidence_level": 0.0,
            "stress_level": 0.0,
            "adaptability": 0.0,
            "decision_making_pattern": "",
            "behavioral_summary": "",
        },
        "updated_memory_state": {
            "focus_trend": "",
            "confidence_trend": "",
            "stress_response_pattern": "",
            "learning_behavior_pattern": "",
            "recommended_future_observation": "",
            "context_summary": "",   # explain WHY these scores — used as context next time
        },
        "mindset_scores": [
            {"mindset_name": "", "score": 0.0}
        ],
        "analysis_confidence": 0.0,
        "analysis_version": request.analysis_version,
    }

    prompt_sections = [
        f"LANGUAGE GUIDANCE:\n{_language_instruction(request.response_language)}",
        "INPUT DATA (JSON):\n" + json.dumps(payload, ensure_ascii=False),
    ]
    if rag_context:
        prompt_sections.append("RETRIEVED CONTEXT:\n" + rag_context)
    prompt_sections.append(
        "Respond ONLY with JSON that matches this schema:\n"
        + json.dumps(output_schema, ensure_ascii=False)
    )

    return "\n\n".join(prompt_sections)