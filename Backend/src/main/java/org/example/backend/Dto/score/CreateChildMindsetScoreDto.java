package org.example.backend.Dto.score;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreateChildMindsetScoreDto {
    private Float score;
    private Integer childId;
    private Integer mindsetId;
}
