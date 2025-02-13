package com.gymapp.demo.service;

import com.gymapp.demo.dto.ProgressAnalyticsDTO;
import com.gymapp.demo.entity.ProgressAnalytics;
import com.gymapp.demo.repositories.ProgressAnalyticsRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ProgressAnalyticsService {

    @Autowired
    private ProgressAnalyticsRepository progressAnalyticsRepository;

    public List<ProgressAnalyticsDTO> getProgressByUserId(Long userId) {
        List<ProgressAnalytics> progressList = progressAnalyticsRepository.findByUserId(userId);
        return progressList.stream()
                .map(progress -> new ProgressAnalyticsDTO(
                        progress.getExerciseName(),
                        progress.getWeight(),
                        progress.getSets(),
                        progress.getReps(),
                        progress.getCreatedAt()))
                .collect(Collectors.toList());
    }

    public List<ProgressAnalyticsDTO> getProgressByExercise(Long userId, String exerciseName) {
        List<ProgressAnalytics> progressList = progressAnalyticsRepository.findByUserIdAndExerciseNameOrderByCreatedAtAsc(userId, exerciseName);
        return progressList.stream()
                .map(progress -> new ProgressAnalyticsDTO(
                        progress.getExerciseName(),
                        progress.getWeight(),
                        progress.getSets(),
                        progress.getReps(),
                        progress.getCreatedAt()))
                .collect(Collectors.toList());
    }

    public ProgressAnalytics saveProgress(ProgressAnalytics progressAnalytics) {
        return progressAnalyticsRepository.save(progressAnalytics);
    }

    public void deleteProgress(Long id) {
        progressAnalyticsRepository.deleteById(id);
    }
}