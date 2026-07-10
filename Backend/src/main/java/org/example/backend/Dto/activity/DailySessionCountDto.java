package org.example.backend.Dto.activity;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class DailySessionCountDto {
    private String date;
    private long count;
}