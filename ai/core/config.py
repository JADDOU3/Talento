from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    # OpenAI
    openai_api_key: str
    analysis_model: str = "gpt-4o-mini"
    whisper_model: str = "gpt-4o-mini-transcribe"
    embedding_model: str = "text-embedding-3-small"

    # Backend API (for seeding)
    backend_timeout_seconds: int = 15

    # ChromaDB
    chroma_host: str = "chromadb"
    chroma_port: int = 8000
    chroma_collection_mindsets: str = "mindset_definitions"
    chroma_collection_criteria: str = "criteria_definitions"
    chroma_collection_activity_criteria: str = "activity_criteria_links"
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