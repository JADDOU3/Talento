from typing import Any

from core.config import get_settings
from models.schemas import AnalysisRequest
from rag.chroma_client import (
    get_mindsets_collection,
    get_criteria_collection,
    get_activity_criteria_collection,
    get_patterns_collection,
    get_rules_collection,
)

settings = get_settings()


def _format_query(request: AnalysisRequest) -> str:
    """
    Builds a single RAG query string from ALL activity summaries combined.
    We merge activity names, types, and aggregate signals into one query
    so ChromaDB returns context relevant to the child's overall session —
    not just one activity.
    """
    aggregate = request.session_aggregate
    summaries = request.activity_summaries

    activity_names = " ".join(s.activity_name for s in summaries)
    activity_types = " ".join(set(s.activity_type for s in summaries))

    # Derive dominant signal levels from the aggregate numbers
    completion_rate = aggregate.completion_rate
    completion_label = "high" if completion_rate >= 0.7 else "medium" if completion_rate >= 0.4 else "low"

    total_hints = aggregate.total_hints_used
    hint_label = "high" if total_hints >= 5 else "medium" if total_hints >= 2 else "low"

    total_fails = aggregate.total_fails
    fail_label = "high" if total_fails >= 4 else "medium" if total_fails >= 2 else "low"

    avg_duration = aggregate.avg_duration_per_activity_seconds
    focus_label = "high" if avg_duration >= 300 else "medium" if avg_duration >= 90 else "low"

    parts = [
        activity_names,
        activity_types,
        f"completion={completion_label}",
        f"hint_dependency={hint_label}",
        f"frustration={fail_label}",
        f"focus={focus_label}",
        f"sessions={aggregate.total_sessions}",
        f"activities={aggregate.total_activities_attempted}",
    ]

    # Also include per-activity behavioral signal words for richer retrieval
    for s in summaries:
        sig = s.behavioral_signals
        parts += [
            sig.persistence.value,
            sig.adaptability.value,
            sig.confidence.value,
        ]

    return " ".join([p for p in parts if p]).strip()


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


def _exact_activity_criteria(request: AnalysisRequest) -> list[str]:
    """
    Pulls activity-criteria records by exact metadata match against the
    activities actually present in this session, rather than relying purely
    on embedding similarity. This guarantees the criteria/weights for the
    child's actual activities are included, instead of being potentially
    crowded out of the top-k by semantically-similar-but-irrelevant records.
    """
    collection = get_activity_criteria_collection()
    try:
        if collection.count() == 0:
            return []
    except Exception:
        return []

    activity_names = list({s.activity_name for s in request.activity_summaries if s.activity_name})
    if not activity_names:
        return []

    where_filter: dict[str, Any] = (
        {"activity_name": {"$in": activity_names}}
        if len(activity_names) > 1
        else {"activity_name": activity_names[0]}
    )

    try:
        result = collection.get(where=where_filter)
    except Exception:
        return []

    documents = result.get("documents") or []
    return [doc for doc in documents if doc]


def _semantic_activity_criteria(query: str, top_k: int) -> list[str]:
    return _query_collection(get_activity_criteria_collection(), query, top_k)


def _dedupe(items: list[str]) -> list[str]:
    seen: set[str] = set()
    result: list[str] = []
    for item in items:
        if item not in seen:
            seen.add(item)
            result.append(item)
    return result


def retrieve_context(request: AnalysisRequest, top_k: int | None = None) -> dict[str, Any]:
    query = _format_query(request)
    limit = top_k or settings.rag_top_k

    mindsets = _query_collection(get_mindsets_collection(), query, limit)
    criteria = _query_collection(get_criteria_collection(), query, limit)
    patterns = _query_collection(get_patterns_collection(), query, limit)
    rules = _query_collection(get_rules_collection(), query, limit)

    # Exact matches for the session's actual activities take priority,
    # supplemented with a semantic pass in case the exact match misses
    # related activity-criteria worth surfacing (e.g. partial name matches
    # are intentionally not attempted here to avoid false positives).
    exact_activity_criteria = _exact_activity_criteria(request)
    semantic_activity_criteria = _semantic_activity_criteria(query, limit)
    activity_criteria = _dedupe(exact_activity_criteria + semantic_activity_criteria)

    return {
        "query": query,
        "mindsets": mindsets,
        "criteria": criteria,
        "activity_criteria": activity_criteria,
        "behavioral_patterns": patterns,
        "interpretation_rules": rules,
    }