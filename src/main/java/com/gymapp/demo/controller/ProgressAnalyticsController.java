package com.gymapp.demo.controller;

import com.gymapp.demo.entity.ProgressAnalytics;
import com.gymapp.demo.service.ProgressAnalyticsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/progress-analytics")
public class ProgressAnalyticsController {
    @Autowired
    private ProgressAnalyticsService progressAnalyticsService;

    @GetMapping("/user/{userId}")
    public List<ProgressAnalytics> getProgressByUserId(@PathVariable Long userId) {
        return progressAnalyticsService.getProgressByUserId(userId);
    }

    @PostMapping
    public ProgressAnalytics createProgressAnalytics(@RequestBody ProgressAnalytics progressAnalytics) {
        return progressAnalyticsService.saveProgress(progressAnalytics);
    }
}