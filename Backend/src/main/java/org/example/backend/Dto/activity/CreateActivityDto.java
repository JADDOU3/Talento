<<<<<<< HEAD:Backend/src/main/java/org/example/backend/Dto/CreateActivityDto.java
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
=======
package org.example.backend.Dto.activity;


import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.util.enums.Type;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class CreateActivityDto {
    private String name;
    private String description;
    private Type type;
}
>>>>>>> 1fa9b86a49e02d460f12550142ed08adf9cf170e:Backend/src/main/java/org/example/backend/Dto/activity/CreateActivityDto.java
