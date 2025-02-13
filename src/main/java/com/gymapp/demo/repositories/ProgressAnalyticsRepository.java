package com.gymapp.demo.repositories;

import com.gymapp.demo.entity.ProgressAnalytics;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ProgressAnalyticsRepository extends JpaRepository<ProgressAnalytics, Long> {
    List<ProgressAnalytics> findByUserId(Long userId);
    List<ProgressAnalytics> findByExerciseName(String exerciseName);
    List<ProgressAnalytics> findByUserIdAndExerciseNameOrderByCreatedAtAsc(Long userId, String exerciseName);
    //Optional<ProgressAnalytics> getProgressByExercise(Long userId, String exerciseName);
    void deleteByExerciseNameAndUserId(String exerciseName, Long userId);

}