package org.example.backend.Dto.ai.common;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class MindsetScoreDto {
    @JsonProperty("mindset_name")
    private String mindsetName;
    private float score;
}