package org.example.backend.Dto.ai.common;

import com.fasterxml.jackson.annotation.JsonAlias;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class MindsetScoreDto {
    @JsonAlias("mindset_name")
    private String mindsetName;
    private float score;
}