package com.gymapp.demo.repositories;

import com.gymapp.demo.entity.Exercise;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ExerciseRepository extends JpaRepository<Exercise, Long> {
    List<Exercise> findByWorkoutId(Long workoutId);

    List<Exercise> findTop10ByWorkout_User_IdOrderByCreatedAtDesc(Long userId);
}