package org.example.backend.Dto.level;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class LevelStorySubmissionResponseDto {

    private int id;
    private String storyText;
    private List<String> matchedKeywords;
    private LocalDateTime submittedAt;

    // Denormalized for convenience — avoids follow-up API calls on the client
    private int levelId;
    private int activitySessionId;
    private int activityId;
    private int childId;
}