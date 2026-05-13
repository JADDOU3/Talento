package org.example.backend.Dto.aiReport;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreateAIReportDto {
    private String summary;
    private LocalDateTime generatedAt;
    private Integer childId;
}
