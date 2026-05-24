package org.example.backend.Dto.ai.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class BehavioralSignalsDto {
    private String hesitation;
    private String persistence;
    private String adaptability;
    private String hintDependency;
    private String frustration;
    private String focus;
    private String confidence;
}


