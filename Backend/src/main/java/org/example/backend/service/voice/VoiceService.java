package org.example.backend.service.voice;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.example.backend.Dto.voice.ActivityVoiceResponse;
import org.example.backend.Dto.voice.VoiceUrlResponse;
import org.example.backend.model.activity.Activity;
import org.example.backend.model.level.Level;
import org.example.backend.model.level.LevelImage;
import org.example.backend.model.voice.GlobalVoiceOver;
import org.example.backend.model.voice.MazeQuestionVoiceOver;
import org.example.backend.model.voice.VoiceOver;
import org.example.backend.repo.activity.ActivityRepo;
import org.example.backend.repo.level.LevelImageRepo;
import org.example.backend.repo.level.LevelRepo;
import org.example.backend.repo.voice.GlobalVoiceOverRepository;
import org.example.backend.repo.voice.MazeQuestionVoiceOverRepository;
import org.example.backend.repo.voice.VoiceOverRepository;
import org.example.backend.service.community.S3Service;
import org.example.backend.util.enums.VoiceType;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
@RequiredArgsConstructor
public class VoiceService {

    private final S3Service s3Service;
    private final GlobalVoiceOverRepository globalVoiceOverRepository;
    private final VoiceOverRepository voiceOverRepository;
    private final MazeQuestionVoiceOverRepository mazeQuestionVoiceOverRepository;
    private final ActivityRepo activityRepository;
    private final LevelRepo levelRepository;
    private final LevelImageRepo levelImageRepository;
    private final ObjectMapper objectMapper = new ObjectMapper();
    // ---- Uploads ----

    public String uploadGlobalVoice(VoiceType type, MultipartFile file) {
        String key = s3Service.uploadFile(file, "voice/global");

        GlobalVoiceOver clip = globalVoiceOverRepository.findByType(type)
                .orElse(new GlobalVoiceOver(0, type, null));
        clip.setS3Key(key);
        globalVoiceOverRepository.save(clip);

        return key;
    }

    // level == null -> intro voice, level != null -> that level's voice
    public String uploadActivityVoice(int activityId, Integer levelId, MultipartFile file) {
        Activity activity = activityRepository.findById(activityId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Activity not found"));

        VoiceOver voiceOver;
        String folder;

        if (levelId == null) {
            voiceOver = voiceOverRepository.findByActivity_IdAndLevelIsNull(activityId)
                    .orElse(new VoiceOver(0, activity, null, null));
            folder = "voice/activity/" + activityId + "/intro";
        } else {
            Level level = levelRepository.findById(levelId)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Level not found"));

            if (level.getActivity() == null || level.getActivity().getId() != activityId) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Level does not belong to this activity");
            }

            voiceOver = voiceOverRepository.findByActivity_IdAndLevel_Id(activityId, levelId)
                    .orElse(new VoiceOver(0, activity, level, null));
            folder = "voice/activity/" + activityId + "/level/" + levelId;
        }

        String key = s3Service.uploadFile(file, folder);
        voiceOver.setS3Key(key);
        voiceOverRepository.save(voiceOver);

        return key;
    }

    public String uploadMazeQuestionVoice(int levelId, int challengeId, MultipartFile file) {
        Level level = levelRepository.findById(levelId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Level not found"));

        validateChallengeExists(levelId, challengeId);

        String key = s3Service.uploadFile(file, "voice/maze/" + levelId + "/" + challengeId);

        MazeQuestionVoiceOver voiceOver = mazeQuestionVoiceOverRepository
                .findByLevel_IdAndChallengeId(levelId, challengeId)
                .orElse(new MazeQuestionVoiceOver(0, level, challengeId, null));
        voiceOver.setS3Key(key);
        mazeQuestionVoiceOverRepository.save(voiceOver);

        return key;
    }

    // ---- Reads ----

    public VoiceUrlResponse getGlobalVoice(VoiceType type) {
        GlobalVoiceOver clip = globalVoiceOverRepository.findByType(type)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "No " + type + " voice configured"));

        String url = s3Service.generatePresignedUrl(clip.getS3Key());
        return new VoiceUrlResponse(url);
    }

    public ActivityVoiceResponse getActivityVoice(int activityId, Integer levelId) {
        if (levelId == null) {
            VoiceOver voiceOver = voiceOverRepository.findByActivity_IdAndLevelIsNull(activityId)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "No intro voice configured for this activity"));

            String url = s3Service.generatePresignedUrl(voiceOver.getS3Key());
            return new ActivityVoiceResponse("intro", null, url);
        }

        VoiceOver voiceOver = voiceOverRepository.findByActivity_IdAndLevel_Id(activityId, levelId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "No voice configured for this level"));

        String url = s3Service.generatePresignedUrl(voiceOver.getS3Key());
        return new ActivityVoiceResponse("level", levelId, url);
    }

    public VoiceUrlResponse getMazeQuestionVoice(int levelId, int challengeId) {
        MazeQuestionVoiceOver voiceOver = mazeQuestionVoiceOverRepository
                .findByLevel_IdAndChallengeId(levelId, challengeId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                        "No voice configured for challenge " + challengeId + " on this level"));

        String url = s3Service.generatePresignedUrl(voiceOver.getS3Key());
        return new VoiceUrlResponse(url);
    }

    // ---- Helpers ----

    // Confirms a LevelImage with role TARGET and this challengeId exists under this level.
    // challengeId isn't a real column on LevelImage, it's inside the `meta` JSON string, so we parse it.
    private void validateChallengeExists(int levelId, int challengeId) {
        List<LevelImage> images = levelImageRepository.findByLevel_Id(levelId);

        boolean found = images.stream()
                .filter(img -> "TARGET".equalsIgnoreCase(img.getRole()))
                .anyMatch(img -> {
                    try {
                        JsonNode node = objectMapper.readTree(img.getMeta());
                        return node.has("challengeId") && node.get("challengeId").asInt() == challengeId;
                    } catch (Exception e) {
                        return false;
                    }
                });

        if (!found) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND,
                    "No maze question with challengeId " + challengeId + " found for this level");
        }
    }
}