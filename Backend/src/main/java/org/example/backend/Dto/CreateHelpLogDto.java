package org.example.backend.Dto;

import lombok.Data;
import org.example.backend.util.enums.HelpLevel;

@Data
public class CreateHelpLogDto {
    private int activitySessionId;
    private HelpLevel helpLevel;
}
