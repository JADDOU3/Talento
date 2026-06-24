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


def _extract_mindset_names(rag: dict) -> list[str]:
    """
    Extracts mindset names from the RAG retrieved mindset definitions.
    Each document looks like: "Mindset: Cognitive. Description: ..."
    Returns e.g. ["Cognitive", "Social-Emotional", "Sensory-Kinesthetic", "Creative-Visual"]
    """
    names = []
    for doc in rag.get("mindsets", []):
        match = re.match(r"Mindset:\s*([^.]+)", doc)
        if match:
            name = match.group(1).strip()
            if name:
                names.append(name)
    return names


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

    # ── Activity summaries ───────────────────────────────────────
    activities_section = [s.model_dump() for s in request.activity_summaries]

    payload = {
        "child_profile": child_section,
        "session_aggregate": aggregate_section,
        "activity_summaries": activities_section,
        "response_language": request.response_language.value,
        "analysis_version": request.analysis_version,
    }

    if request.previous_analysis_summary:
        payload["previous_analysis_summary"] = request.previous_analysis_summary.model_dump(exclude_none=True)

    if request.parent_note:
        payload["parent_note"] = request.parent_note

    # ── RAG context ──────────────────────────────────────────────
    rag_context = _format_rag_context(rag)

    # ── Mindset names from RAG — tell AI exactly what to use ─────
    mindset_names = _extract_mindset_names(rag)
    if not mindset_names:
        # Fallback if RAG returned nothing — use known defaults
        mindset_names = ["Cognitive", "Social-Emotional", "Sensory-Kinesthetic", "Creative-Visual"]

    mindset_scores_schema = [
        {"mindset_name": name, "score": -1}
        for name in mindset_names
    ]

    mindset_instruction = (
        f"You MUST score ALL of these mindsets: {mindset_names}. "
        "Score each from 0.0 (not observed) to 1.0 (strongly observed) based on the child's actual behavior. "
        "Do NOT return 0.0 for all — derive real scores from the data. "
        "CRITICAL: The mindset_name values in your response must be EXACTLY: "
        + str(mindset_names) +
        ". Do not change, translate, or nullify them."
    )

    output_instructions = f"""Respond ONLY with a JSON object with this exact structure. All values must be derived from the input data — do NOT use placeholder zeroes or empty strings:

{{
  "instant_analysis": {{
    "focus_level": <float 0.0-1.0 based on session duration and engagement>,
    "confidence_level": <float 0.0-1.0 based on attempts and independence>,
    "stress_level": <float 0.0-1.0 based on fails, rage quits, frustration signals>,
    "adaptability": <float 0.0-1.0 based on strategy changes and recovery from failure>,
    "decision_making_pattern": <short descriptive string e.g. "impulsive", "cautious", "strategic">,
    "behavioral_summary": <2-4 sentence narrative summary of the child's behavior across all sessions>
  }},
  "updated_memory_state": {{
    "focus_trend": <"improving" | "declining" | "stable" | "low" | "high">,
    "confidence_trend": <"improving" | "declining" | "stable" | "low" | "high">,
    "stress_response_pattern": <short string describing how child handles stress>,
    "learning_behavior_pattern": <short string describing how child learns>,
    "recommended_future_observation": <1-2 sentences on what to watch next>,
    "context_summary": <2-3 sentences explaining WHY these specific scores — used as context in next analysis>
  }},
  "mindset_scores": {json.dumps(mindset_scores_schema)},
  "analysis_confidence": <float 0.0-1.0 reflecting how confident you are given the available data>,
  "analysis_version": "{request.analysis_version}"
}}

For mindset_scores: the mindset_name values are already set — do NOT change them. Replace the -1 score values with your actual assessment (0.0 to 1.0)."""

    prompt_sections = [
        f"LANGUAGE GUIDANCE:\n{_language_instruction(request.response_language)}",
        f"MINDSET SCORING INSTRUCTIONS:\n{mindset_instruction}",
        "INPUT DATA (JSON):\n" + json.dumps(payload, ensure_ascii=False),
    ]
    if rag_context:
        prompt_sections.append("RETRIEVED CONTEXT:\n" + rag_context)
    prompt_sections.append(output_instructions)

    return "\n\n".join(prompt_sections)