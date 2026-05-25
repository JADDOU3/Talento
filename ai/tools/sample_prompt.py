from models.schemas import (
    AnalysisRequest,
    ActivitySummary,
    BehavioralSignals,
    ChildProfile,
    CompletionStatus,
    Language,
)
from prompt.prompt_builder import build_user_prompt, SYSTEM_PROMPT


def main() -> None:
    request = AnalysisRequest(
        child_profile=ChildProfile(
            child_id=1024,
            age=9,
            gender="male",
            baseline_traits=["introverted", "high curiosity"],
        ),
        activity_summary=ActivitySummary(
            activity_id=7781,
            activity_name="Building Tower",
            activity_type="problem_solving_game",
            duration_seconds=420,
            completion_status=CompletionStatus.COMPLETED,
            attempt_count=4,
            hints_used=2,
            fail_count=5,
            rage_quit=False,
            behavioral_signals=BehavioralSignals(
                hesitation="medium",
                persistence="high",
                adaptability="low",
                hint_dependency="medium",
                frustration="medium",
                focus="medium",
                confidence="low",
            ),
            behavioral_observations=[
                "Paused multiple times before final decisions",
                "Repeated same strategy twice despite failure",
                "Performance improved after hint",
            ],
        ),
        response_language=Language.ENGLISH,
        analysis_version="v1",
    )
    prompt = build_user_prompt(request, rag={})
    print("SYSTEM PROMPT:\n")
    print(SYSTEM_PROMPT)
    print("\nUSER PROMPT:\n")
    print(prompt)


if __name__ == "__main__":
    main()

