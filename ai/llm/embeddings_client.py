from typing import List, Optional
from openai import AsyncOpenAI
from core.config import get_settings

settings = get_settings()
_client: Optional[AsyncOpenAI] = None


def _get_client() -> AsyncOpenAI:
    global _client
    if _client is None:
        _client = AsyncOpenAI(api_key=settings.openai_api_key)
    return _client


async def embed_texts(texts: List[str]) -> List[List[float]]:
    if not texts:
        return []
    client = _get_client()
    response = await client.embeddings.create(
        model=settings.embedding_model,
        input=texts
    )
    return [item.embedding for item in response.data]

