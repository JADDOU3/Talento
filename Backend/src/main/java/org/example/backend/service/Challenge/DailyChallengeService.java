package org.example.backend.service.Challenge;

import org.example.backend.Dto.challenge.dailyChallenge.DailyChallengeAnswerDto;
import org.example.backend.Dto.challenge.dailyChallenge.DailyChallengeResponseDto;
import org.example.backend.Dto.challenge.dailyChallenge.DailyChallengeResultDto;
import org.example.backend.model.DailyChallenge;
import org.example.backend.repo.DailyChallengeRepo;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
public class DailyChallengeService {

    private final DailyChallengeRepo dailyChallengeRepo;

    public DailyChallengeService(DailyChallengeRepo dailyChallengeRepo) {
        this.dailyChallengeRepo = dailyChallengeRepo;
    }

    public DailyChallengeResponseDto getDailyChallenge() {
        List<DailyChallenge> all = dailyChallengeRepo.findAll();
        if (all.isEmpty()) return null;

        // Deterministic daily pick — same question for everyone on the same day
        // changes automatically every day without any scheduled job
        int index = (int) (LocalDate.now().toEpochDay() % all.size());
        return DailyChallengeResponseDto.from(all.get(index));
    }

    public DailyChallengeResultDto checkAnswer(DailyChallengeAnswerDto dto) {
        DailyChallenge challenge = dailyChallengeRepo.findById(dto.getChallengeId())
                .orElse(null);
        if (challenge == null) return null;

        boolean correct = challenge.getCorrectAnswer()
                .trim()
                .equalsIgnoreCase(dto.getAnswer().trim());

        return new DailyChallengeResultDto(correct, challenge.getCorrectAnswer());
    }
}