package org.example.backend.Dto.activityPreference;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UpdateActivityPreferenceDto {
    private Integer timesStarted;
    private Integer timesRepeated;
    private Integer timesCompleted;
    private LocalDateTime lastPlayed;
}
