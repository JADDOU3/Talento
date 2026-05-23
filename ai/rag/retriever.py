from typing import Any

from core.config import get_settings
from models.schemas import AnalysisRequest
from rag.chroma_client import (
    get_mindsets_collection,
    get_criteria_collection,
    get_patterns_collection,
    get_rules_collection,
)

settings = get_settings()


def _format_query(request: AnalysisRequest) -> str:
    summary = request.activity_summary
    signals = summary.behavioral_signals
    observations = "; ".join(summary.behavioral_observations)
    parts = [
        summary.activity_name,
        summary.activity_type,
        f"completion={summary.completion_status}",
        f"attempts={summary.attempt_count}",
        f"hints={summary.hints_used}",
        f"fails={summary.fail_count}",
        f"rage_quit={summary.rage_quit}",
        f"hesitation={signals.hesitation}",
        f"persistence={signals.persistence}",
        f"adaptability={signals.adaptability}",
        f"hint_dependency={signals.hint_dependency}",
        f"frustration={signals.frustration}",
        f"focus={signals.focus}",
        f"confidence={signals.confidence}",
        observations,
    ]
    return " ".join([part for part in parts if part]).strip()


def _query_collection(collection, query: str, top_k: int) -> list[str]:
    if not query:
        return []
    try:
        count = collection.count()
        if count == 0:
            return []
        result = collection.query(query_texts=[query], n_results=min(top_k, count))
    except Exception:
        return []
    documents = result.get("documents") or []
    if not documents:
        return []
    return [doc for doc in documents[0] if doc]


def retrieve_context(request: AnalysisRequest, top_k: int | None = None) -> dict[str, Any]:
    query = _format_query(request)
    limit = top_k or settings.rag_top_k
    mindsets = _query_collection(get_mindsets_collection(), query, limit)
    criteria = _query_collection(get_criteria_collection(), query, limit)
    patterns = _query_collection(get_patterns_collection(), query, limit)
    rules = _query_collection(get_rules_collection(), query, limit)

    return {
        "query": query,
        "mindsets": mindsets,
        "criteria": criteria,
        "behavioral_patterns": patterns,
        "interpretation_rules": rules,
    }
