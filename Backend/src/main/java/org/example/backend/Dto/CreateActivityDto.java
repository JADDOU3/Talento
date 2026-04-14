package org.example.backend.Dto;


import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.RequiredArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class CreateActivityDto {
    private String name;
    private String description;
    private String type; //todo change it to enum later
}
