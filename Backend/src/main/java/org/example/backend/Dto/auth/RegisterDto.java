<<<<<<< HEAD:Backend/src/main/java/org/example/backend/Dto/RegisterDto.java
package org.example.backend.Dto;

import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.util.Gender;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class RegisterDto {
    private String name;
    private String email;
    @Enumerated(EnumType.STRING)
    private Gender gender;// *** Changed datatype from String to Gender and  name from Gender to gender, delete comment after review ^_^ ***
    private String password;
}
=======
package org.example.backend.Dto.auth;

import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.example.backend.util.enums.Gender;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class RegisterDto {
    private String name;
    private String email;
    @Enumerated(EnumType.STRING)
    private Gender gender;
    private String password;
}
>>>>>>> 1fa9b86a49e02d460f12550142ed08adf9cf170e:Backend/src/main/java/org/example/backend/Dto/auth/RegisterDto.java
