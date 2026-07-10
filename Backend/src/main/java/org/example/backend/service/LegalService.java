package org.example.backend.service;

import lombok.RequiredArgsConstructor;
import org.example.backend.service.community.S3Service;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class LegalService {

    private final S3Service s3Service;

    @Value("${privacy.policy.key}")
    private String privacyPolicyKey;

    public String getPrivacyPolicyUrl() {
        return s3Service.generatePresignedUrl(privacyPolicyKey);
    }
}