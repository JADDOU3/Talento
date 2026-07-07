package org.example.backend.service.Challenge;

import org.example.backend.Dto.challenge.dailyChallenge.DailyChallengeAnswerDto;
import org.example.backend.Dto.challenge.dailyChallenge.DailyChallengeResponseDto;
import org.example.backend.Dto.challenge.dailyChallenge.DailyChallengeResultDto;
import org.example.backend.model.Child;
import org.example.backend.model.DailyChallenge;
import org.example.backend.model.DailyChallengeAttempt;
import org.example.backend.repo.challenge.DailyChallengeAttemptRepo;
import org.example.backend.repo.challenge.DailyChallengeRepo;
import org.example.backend.service.ChildService;
import org.example.backend.service.CoinService;
import org.example.backend.util.enums.CoinReason;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Service
public class DailyChallengeService {

    private final DailyChallengeRepo dailyChallengeRepo;
    private final DailyChallengeAttemptRepo attemptRepo;
    private final ChildService childService;
    private final CoinService coinService;

    public DailyChallengeService(DailyChallengeRepo dailyChallengeRepo,
                                 DailyChallengeAttemptRepo attemptRepo,
                                 ChildService childService,
                                 CoinService coinService) {
        this.dailyChallengeRepo = dailyChallengeRepo;
        this.attemptRepo = attemptRepo;
        this.childService = childService;
        this.coinService = coinService;
    }

    public DailyChallengeResponseDto getDailyChallenge() {
        List<DailyChallenge> all = dailyChallengeRepo.findAllByOrderByIdAsc();
        if (all.isEmpty()) return null;

        int index = (int) (LocalDate.now().toEpochDay() % all.size());
        DailyChallenge challenge = all.get(index);

        Child child = childService.getSelectedChild();
        if (child != null) {
            Optional<DailyChallengeAttempt> attempt =
                    attemptRepo.findByChildIdAndAttemptDate(child.getId(), LocalDate.now());
            if (attempt.isPresent()) {
                return DailyChallengeResponseDto.fromWithAttempt(challenge, attempt.get());
            }
        }

        return DailyChallengeResponseDto.from(challenge);
    }

    public DailyChallengeResultDto checkAnswer(DailyChallengeAnswerDto dto) {
        DailyChallenge challenge = dailyChallengeRepo.findById(dto.getChallengeId())
                .orElse(null);
        if (challenge == null) return null;

        Child child = childService.getSelectedChild();

        if (child != null) {
            Optional<DailyChallengeAttempt> existing =
                    attemptRepo.findByChildIdAndAttemptDate(child.getId(), LocalDate.now());
            if (existing.isPresent()) {
                return new DailyChallengeResultDto(
                        existing.get().isCorrect(), challenge.getCorrectAnswer());
            }
        }

        boolean correct = challenge.getCorrectAnswer().trim()
                .equals(dto.getAnswer().trim());

        if (child != null) {
            attemptRepo.save(new DailyChallengeAttempt(
                    0, child.getId(), dto.getChallengeId(),
                    dto.getAnswer(), correct, LocalDate.now()
            ));

            if (correct) {
                coinService.awardCoins(child, CoinReason.DAILY_CHALLENGE);
            }
        }

        return new DailyChallengeResultDto(correct, challenge.getCorrectAnswer());
    }
}