package com.gymapp.demo.service;

import com.gymapp.demo.entity.Exercise;
import com.gymapp.demo.repositories.ExerciseRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ExerciseService {

    @Autowired
    private ExerciseRepository exerciseRepository;

    public List<Exercise> getExercisesByWorkoutId(Long workoutId) {
        return exerciseRepository.findByWorkoutId(workoutId);
    }

    public Exercise saveExercise(Exercise exercise) {
        return exerciseRepository.save(exercise);
    }

    public void deleteExercise(Long id) {
        exerciseRepository.deleteById(id);
    }
}