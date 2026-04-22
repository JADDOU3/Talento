package org.example.backend.Dto.activity;


import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class AssignActivityToKitDto {
    private int activityId;
    private int kitId;
}
