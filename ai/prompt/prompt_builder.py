import json

from models.schemas import AnalysisRequest, Language

SYSTEM_PROMPT = (
    "You are a child behavioral analysis AI specialized in learning patterns through play. "
    "You analyze aggregated data from educational game sessions to produce actionable insights for parents and educators. "
    "CRITICAL RULES:\n"
    "1. Never diagnose. Describe behavioral patterns only.\n"
    "2. A child with completion_rate >= 0.6 is performing WELL — do not describe them negatively.\n"
    "3. A child with success_rate >= 0.7 has HIGH confidence — failing 30% of attempts is completely normal.\n"
    "4. fails_per_level <= 2 is NORMAL for children — do not flag this as frustration or struggling.\n"
    "5. duration_per_level between 45 and 300 seconds indicates GOOD engagement — not hesitation.\n"
    "6. attempts_per_level between 1 and 3 is NORMAL — do not treat this as a negative signal.\n"
    "7. Always interpret metrics relative to age-appropriate expectations — children are not adults.\n"
    "8. If previous_analysis_summary is provided with a context_summary, your scores MUST evolve "
    "from that baseline — do not restart from scratch. Explain what changed and why.\n"
    "9. context_summary must clearly explain the specific data points that drove your scores "
    "so the next analysis understands your reasoning chain.\n"
    "10. behavioral_summary must be warm, encouraging, and specific — parents and educators will read this. "
    "Mention what the child does WELL before noting any areas to develop.\n"
    "11. Only flag genuinely negative patterns when the data strongly supports it: "
    "success_rate < 0.4, completion_rate < 0.3, or consistent abandonment across multiple sessions.\n"
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