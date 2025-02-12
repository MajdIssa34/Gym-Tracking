package com.gymapp.demo.repositories;

import com.gymapp.demo.entity.ProgressAnalytics;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProgressAnalyticsRepository extends JpaRepository<ProgressAnalytics, Long> {
    List<ProgressAnalytics> findByUserId(Long userId);
    List<ProgressAnalytics> findByExerciseName(String exerciseName);
}