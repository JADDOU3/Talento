import json

from models.schemas import AnalysisRequest, Language

SYSTEM_PROMPT = (
    "You are a behavioral analysis AI specialized in children's cognitive and emotional patterns. "
    "Analyze the child's activity behavior and update their psychological state objectively. "
    "Do not make medical diagnoses. Focus on behavioral indicators, emotional responses, "
    "confidence, attention patterns, adaptability, frustration handling, and learning tendencies. "
    "Always respond with valid JSON only."
)


def _language_instruction(language: Language) -> str:
    if language == Language.ARABIC:
        return (
            "Write behavioral_summary and recommended_future_observation in Arabic. "
            "Keep other fields in English."
        )
    return "Write behavioral_summary and recommended_future_observation in English."


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
    child_profile = {
        "age": request.child_profile.age,
        "gender": request.child_profile.gender,
        "baseline_traits": request.child_profile.baseline_traits,
    }
    payload = {
        "child_profile": child_profile,
        "activity_summary": request.activity_summary.model_dump(),
        "response_language": request.response_language.value,
        "analysis_version": request.analysis_version,
    }
    if request.previous_analysis_summary:
        payload["previous_analysis_summary"] = request.previous_analysis_summary.model_dump()
    if request.parent_note:
        payload["parent_note"] = request.parent_note

    rag_context = _format_rag_context(rag)
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
