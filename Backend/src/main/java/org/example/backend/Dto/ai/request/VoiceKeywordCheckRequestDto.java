package org.example.backend.Dto.ai.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class VoiceKeywordCheckRequestDto {

    private int activityId;

    /**
     * Optional. If provided together with levelId, the story is saved on success.
     * If either is missing, the check still runs but nothing is persisted.
     */
    private Integer activitySessionId;

    /**
     * Optional. Must be provided together with activitySessionId to trigger a save.
     */
    private Integer levelId;

    private List<String> keywords;
}