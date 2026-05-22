import argparse
import asyncio
import json
import os
from typing import Any, Iterable
from uuid import uuid4

import httpx

from core.config import get_settings
from core.backend_endpoints import (
    BACKEND_BASE_URL,
    BACKEND_MINDSETS_PATH,
    BACKEND_CRITERIA_PATH,
    BACKEND_ACTIVITY_CRITERIA_PATH,
)
from llm.embeddings_client import embed_texts
from rag.chroma_client import (
    get_mindsets_collection,
    get_criteria_collection,
    get_patterns_collection,
    get_rules_collection,
)

settings = get_settings()


def _chunked(items: list[dict[str, Any]], size: int) -> Iterable[list[dict[str, Any]]]:
    for i in range(0, len(items), size):
        yield items[i:i + size]


def _doc_id(prefix: str, primary: Any | None, fallback: Any | None) -> str:
    if primary is not None and str(primary).strip():
        return f"{prefix}:{primary}"
    if fallback is not None and str(fallback).strip():
        return f"{prefix}:{fallback}"
    return f"{prefix}:{uuid4().hex}"


def _get_text(value: Any) -> str:
    return str(value).strip() if value is not None else ""


def _build_mindset_records(mindsets: list[dict[str, Any]]) -> list[dict[str, Any]]:
    records: list[dict[str, Any]] = []
    for item in mindsets:
        name = _get_text(item.get("name"))
        description = _get_text(item.get("description"))
        criteria = item.get("criteria") or []
        criteria_names = ", ".join(
            [_get_text(c.get("name")) for c in criteria if _get_text(c.get("name"))]
        )
        document = (
            f"Mindset: {name}. Description: {description}. Criteria: {criteria_names}."
        ).strip()
        records.append({
            "id": _doc_id("mindset", item.get("id"), name),
            "document": document,
            "metadata": {
                "type": "mindset",
                "mindset_id": item.get("id"),
                "name": name,
            },
        })
    return records


def _build_criteria_records(criteria: list[dict[str, Any]]) -> list[dict[str, Any]]:
    records: list[dict[str, Any]] = []
    for item in criteria:
        name = _get_text(item.get("name"))
        weight = item.get("weight")
        mindset = item.get("mindset") or {}
        mindset_name = _get_text(mindset.get("name"))
        document = (
            f"Criteria: {name}. Weight: {weight}. Mindset: {mindset_name}."
        ).strip()
        records.append({
            "id": _doc_id("criteria", item.get("id"), name),
            "document": document,
            "metadata": {
                "type": "criteria",
                "criteria_id": item.get("id"),
                "name": name,
                "mindset_name": mindset_name,
                "weight": weight,
            },
        })
    return records


def _build_activity_criteria_records(activity_criteria: list[dict[str, Any]]) -> list[dict[str, Any]]:
    records: list[dict[str, Any]] = []
    for item in activity_criteria:
        activity = item.get("activity") or {}
        criteria = item.get("criteria") or {}
        activity_id = item.get("activityId") or activity.get("id")
        activity_name = _get_text(item.get("activityName") or activity.get("name"))
        criteria_id = item.get("criteriaId") or criteria.get("id")
        criteria_name = _get_text(item.get("criteriaName") or criteria.get("name"))
        weight = item.get("weight")
        document = (
            "Activity criteria: "
            f"activity={activity_name}, criteria={criteria_name}, weight={weight}."
        ).strip()
        records.append({
            "id": _doc_id("activity_criteria", item.get("id"), f"{activity_id}-{criteria_id}"),
            "document": document,
            "metadata": {
                "type": "activity_criteria",
                "activity_id": activity_id,
                "activity_name": activity_name,
                "criteria_id": criteria_id,
                "criteria_name": criteria_name,
                "weight": weight,
            },
        })
    return records


def _load_seed_file(filename: str) -> list[dict[str, Any]]:
    path = os.path.join(settings.seed_data_path, filename)
    if not os.path.exists(path):
        return []
    with open(path, "r", encoding="utf-8") as file:
        data = json.load(file)
    if isinstance(data, list):
        return data
    return []


def _build_static_records(items: list[dict[str, Any]], record_type: str) -> list[dict[str, Any]]:
    records: list[dict[str, Any]] = []
    for item in items:
        title = _get_text(item.get("title"))
        content = _get_text(item.get("content"))
        tags = item.get("tags") or []
        tag_list = ", ".join([_get_text(tag) for tag in tags if _get_text(tag)])
        document = f"{title}. {content}. Tags: {tag_list}.".strip()
        records.append({
            "id": _doc_id(record_type, item.get("id"), title),
            "document": document,
            "metadata": {
                "type": record_type,
                "title": title,
                "tags": tags,
            },
        })
    return records


async def _upsert_records(collection, records: list[dict[str, Any]]) -> None:
    if not records:
        return
    for batch in _chunked(records, settings.chroma_seed_batch_size):
        documents = [item["document"] for item in batch]
        embeddings = await embed_texts(documents)
        collection.upsert(
            ids=[item["id"] for item in batch],
            documents=documents,
            metadatas=[item["metadata"] for item in batch],
            embeddings=embeddings,
        )


async def _fetch_backend_list(client: httpx.AsyncClient, path: str) -> list[dict[str, Any]]:
    url = BACKEND_BASE_URL.rstrip("/") + path
    response = await client.get(url)
    response.raise_for_status()
    payload = response.json()
    if isinstance(payload, dict) and "data" in payload:
        payload = payload["data"]
    if not isinstance(payload, list):
        raise ValueError(f"Unexpected response from {url}")
    return payload


async def seed_from_backend(token: str | None, auth_header: str) -> None:
    timeout = httpx.Timeout(settings.backend_timeout_seconds)
    headers: dict[str, str] = {}
    if token:
        headers[auth_header] = token
    async with httpx.AsyncClient(timeout=timeout, headers=headers) as client:
        mindsets = await _fetch_backend_list(client, BACKEND_MINDSETS_PATH)
        criteria = await _fetch_backend_list(client, BACKEND_CRITERIA_PATH)
        activity_criteria = await _fetch_backend_list(client, BACKEND_ACTIVITY_CRITERIA_PATH)

    await _upsert_records(get_mindsets_collection(), _build_mindset_records(mindsets))
    criteria_records = _build_criteria_records(criteria) + _build_activity_criteria_records(activity_criteria)
    await _upsert_records(get_criteria_collection(), criteria_records)


async def seed_from_files() -> None:
    patterns = _load_seed_file("behavioral_patterns.json")
    rules = _load_seed_file("interpretation_rules.json")

    await _upsert_records(get_patterns_collection(), _build_static_records(patterns, "behavioral_pattern"))
    await _upsert_records(get_rules_collection(), _build_static_records(rules, "interpretation_rule"))


async def seed_all(token: str | None, auth_header: str) -> None:
    await seed_from_backend(token, auth_header)
    await seed_from_files()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Seed ChromaDB from backend and local data (pass a JWT token if backend auth is enabled)"
    )
    parser.add_argument(
        "--token",
        default=None,
        help="Auth token for backend requests (include any 'Bearer ' prefix if required)",
    )
    parser.add_argument("--auth-header", default="Authorization", help="Auth header name")
    args = parser.parse_args()

    asyncio.run(seed_all(args.token, args.auth_header))
