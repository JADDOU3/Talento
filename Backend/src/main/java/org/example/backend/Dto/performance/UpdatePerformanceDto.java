package org.example.backend.Dto.performance;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UpdatePerformanceDto {
    private Float completionScore;
    private Float efficiencyScore;
    private Float persistenceScore;
    private Float independenceScore;
    private Float strategyScore;
}
