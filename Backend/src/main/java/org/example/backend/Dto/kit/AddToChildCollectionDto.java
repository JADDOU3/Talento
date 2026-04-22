package org.example.backend.Dto.kit;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class AddToChildCollectionDto {
    private int kitId;
    private int childId;
}
