import chromadb
from chromadb import Collection
from core.config import get_settings

settings = get_settings()

_client: chromadb.HttpClient = None


def get_chroma_client() -> chromadb.HttpClient:
    global _client
    if _client is None:
        _client = chromadb.HttpClient(
            host=settings.chroma_host,
            port=settings.chroma_port
        )
    return _client


def get_collection(name: str) -> Collection:
    client = get_chroma_client()
    return client.get_or_create_collection(
        name=name,
        metadata={"hnsw:space": "cosine"}
    )


def get_mindsets_collection() -> Collection:
    return get_collection(settings.chroma_collection_mindsets)


def get_criteria_collection() -> Collection:
    return get_collection(settings.chroma_collection_criteria)


def get_patterns_collection() -> Collection:
    return get_collection(settings.chroma_collection_patterns)


def get_rules_collection() -> Collection:
    return get_collection(settings.chroma_collection_rules)