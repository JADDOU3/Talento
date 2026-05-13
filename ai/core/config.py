from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    # OpenAI
    openai_api_key: str
    analysis_model: str = "gpt-4o-mini"
    whisper_model: str = "whisper-1"
    embedding_model: str = "text-embedding-3-small"

    # Backend API (for seeding)
    backend_base_url: str = "http://backend:8080"
    backend_mindsets_path: str = "/api/mindsets"
    backend_criteria_path: str = "/api/criteria"
    backend_activity_criteria_path: str = "/api/activity-criteria"
    backend_timeout_seconds: int = 15
    backend_auth_header: str = "Authorization"
    backend_auth_token: str | None = None

    # ChromaDB
    chroma_host: str = "chromadb"
    chroma_port: int = 8001
    chroma_collection_mindsets: str = "mindset_definitions"
    chroma_collection_criteria: str = "activity_criteria"
    chroma_collection_patterns: str = "behavioral_patterns"
    chroma_collection_rules: str = "interpretation_rules"
    chroma_seed_batch_size: int = 64
    seed_data_path: str = "seed_data"
    rag_top_k: int = 4

    # App
    app_env: str = "development"
    max_prompt_tokens: int = 1200

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


@lru_cache
def get_settings() -> Settings:
    return Settings()