package org.example.backend.Dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class SessionDto {
    private LocalDateTime startedAt;
    private LocalDateTime endedAt;

     private int childId;

     private int kitId;
}
