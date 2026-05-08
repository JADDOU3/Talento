package org.example.backend.Dto.event;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.util.enums.HelpLevel;


@Data
@AllArgsConstructor
@NoArgsConstructor
public class CreateHelpEventDto {
    private int childId;
    private int sessionId;
    private HelpLevel helpLevel;
}
