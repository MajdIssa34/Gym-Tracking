package com.gymapp.demo.service;

import com.gymapp.demo.entity.ProgressAnalytics;
import com.gymapp.demo.repositories.ProgressAnalyticsRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ProgressAnalyticsService {

    @Autowired
    private ProgressAnalyticsRepository progressAnalyticsRepository;

    public List<ProgressAnalytics> getProgressByUserId(Long userId) {
        return progressAnalyticsRepository.findByUserId(userId);
    }

    public List<ProgressAnalytics> getProgressByExerciseName(String exerciseName) {
        return progressAnalyticsRepository.findByExerciseName(exerciseName);
    }

    public ProgressAnalytics saveProgress(ProgressAnalytics progressAnalytics) {
        return progressAnalyticsRepository.save(progressAnalytics);
    }

    public void deleteProgress(Long id) {
        progressAnalyticsRepository.deleteById(id);
    }
}