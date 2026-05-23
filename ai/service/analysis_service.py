from models.schemas import AnalysisRequest, AnalysisResponse
from prompt.prompt_builder import SYSTEM_PROMPT, build_user_prompt
from rag.retriever import retrieve_context
from llm.analysis_client import run_analysis


async def run_analysis_service(request: AnalysisRequest) -> AnalysisResponse:
    rag_context = retrieve_context(request)
    user_prompt = build_user_prompt(request, rag_context)
    result = await run_analysis(SYSTEM_PROMPT, user_prompt)
    if "analysis_version" not in result:
        result["analysis_version"] = request.analysis_version
    try:
        return AnalysisResponse.model_validate(result)
    except Exception as exc:
        raise ValueError(f"LLM returned unexpected structure: {exc}\nRaw: {result}")
