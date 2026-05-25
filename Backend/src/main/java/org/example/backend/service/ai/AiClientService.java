package org.example.backend.service.ai;

import org.example.backend.Dto.ai.request.AiAnalysisRequestDto;
import org.example.backend.Dto.ai.response.AiAnalysisResponseDto;
import org.example.backend.Dto.ai.response.AiVoiceResponseDto;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;

@Service
public class AiClientService {
    private final RestTemplate restTemplate;
    private final String baseUrl;

    public AiClientService(RestTemplate restTemplate, @Value("${ai.base-url}") String baseUrl) {
        this.restTemplate = restTemplate;
        this.baseUrl = baseUrl;
    }

    public AiAnalysisResponseDto analyze(AiAnalysisRequestDto request) {
        return restTemplate.postForObject(baseUrl + "/analyze", request, AiAnalysisResponseDto.class);
    }

    public AiVoiceResponseDto transcribe(MultipartFile file) throws IOException {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.MULTIPART_FORM_DATA);

        MultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
        body.add("file", new ByteArrayResource(file.getBytes()) {
            @Override
            public String getFilename() {
                return file.getOriginalFilename() != null ? file.getOriginalFilename() : "audio";
            }
        });

        HttpEntity<MultiValueMap<String, Object>> requestEntity = new HttpEntity<>(body, headers);
        ResponseEntity<AiVoiceResponseDto> response = restTemplate.postForEntity(
            baseUrl + "/voice/transcribe",
            requestEntity,
            AiVoiceResponseDto.class
        );
        return response.getBody();
    }
}
