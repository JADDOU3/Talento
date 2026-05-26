package org.example.backend.controller.community;

import lombok.RequiredArgsConstructor;
import org.example.backend.service.community.S3Service;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

@RestController
@RequestMapping("/api/media")
@RequiredArgsConstructor
public class MediaController {

    private final S3Service s3Service;

   
    @PostMapping("/upload")
    public ResponseEntity<Map<String, String>> uploadMedia(
            @RequestParam("file") MultipartFile file) {

        if (file.isEmpty()) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "File must not be empty"));
        }

        String s3Key = s3Service.uploadFile(file, "posts");
        return ResponseEntity.ok(Map.of("s3Key", s3Key));
    }

    @PostMapping("/upload/level/{gameName}")
    public ResponseEntity<Map<String, String>> uploadLevelMedia(
            @PathVariable String gameName,
            @RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "File must not be empty"));
        }
        if (gameName == null || gameName.isBlank()) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Game name must not be empty"));
        }
        String normalizedName = gameName.trim().toLowerCase().replace(" ", "-");
        String s3Key = s3Service.uploadFile(file, "level/" + normalizedName);
        return ResponseEntity.ok(Map.of("s3Key", s3Key));
    }
}