import json
from typing import Any, Optional

from openai import AsyncOpenAI

from core.config import get_settings

settings = get_settings()
_client: Optional[AsyncOpenAI] = None


def _get_client() -> AsyncOpenAI:
    global _client
    if _client is None:
        _client = AsyncOpenAI(api_key=settings.openai_api_key)
    return _client


def _extract_json(text: str) -> dict[str, Any]:
    text = text.strip()
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        start = text.find("{")
        end = text.rfind("}")
        if start == -1 or end == -1 or start >= end:
            raise
        return json.loads(text[start:end + 1])


async def run_analysis(system_prompt: str, user_prompt: str) -> dict[str, Any]:
    client = _get_client()
    response = await client.chat.completions.create(
        model=settings.analysis_model,
        temperature=0.2,
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt},
        ],
        response_format={"type": "json_object"},
    )

    content = response.choices[0].message.content or ""
    try:
        return _extract_json(content)
    except json.JSONDecodeError:
        # Retry once without response_format in case the model returned non-JSON tokens.
        retry = await client.chat.completions.create(
            model=settings.analysis_model,
            temperature=0.2,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ],
        )
        retry_content = retry.choices[0].message.content or ""
        return _extract_json(retry_content)

