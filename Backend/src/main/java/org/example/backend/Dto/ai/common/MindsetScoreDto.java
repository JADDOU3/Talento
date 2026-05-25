package org.example.backend.Dto.ai.common;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class MindsetScoreDto {
    private String mindsetName;
    private float score;
}


