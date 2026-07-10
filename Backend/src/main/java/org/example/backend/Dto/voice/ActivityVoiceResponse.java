package org.example.backend.Dto.voice;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ActivityVoiceResponse {
    private String scope;   // "intro" or "level"
    private Integer levelId;
    private String url;
}