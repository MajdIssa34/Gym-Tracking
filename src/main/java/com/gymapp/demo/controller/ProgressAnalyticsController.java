package com.gymapp.demo.controller;

import com.gymapp.demo.dto.ProgressAnalyticsDTO;
import com.gymapp.demo.service.ProgressAnalyticsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/progress-analytics")
public class ProgressAnalyticsController {

    @Autowired
    private ProgressAnalyticsService progressAnalyticsService;

    /**
     * ✅ Get all progress analytics for a user (Returns only necessary fields).
     */
    @GetMapping("/user/{userId}")
    public List<ProgressAnalyticsDTO> getAllProgressByUser(@PathVariable Long userId) {
        return progressAnalyticsService.getProgressByUserId(userId);
    }

    /**
     * ✅ Get progress analytics for a specific exercise.
     */
    @GetMapping("/user/{userId}/exercise/{exerciseName}")
    public List<ProgressAnalyticsDTO> getProgressByExercise(@PathVariable Long userId, @PathVariable String exerciseName) {
        return progressAnalyticsService.getProgressByExercise(userId, exerciseName);
    }
}
