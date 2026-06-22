package org.example.backend.Dto.ai.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class VoiceKeywordCheckResponseDto {

    private String text;
    private boolean success;
    private List<String> missingKeywords;
    private String message;

    /**
     * The ID of the persisted story submission.
     * Null when:
     *  - success is false (we never save failures)
     *  - activitySessionId or levelId were not sent in the request
     */
    private Integer savedSubmissionId;
}