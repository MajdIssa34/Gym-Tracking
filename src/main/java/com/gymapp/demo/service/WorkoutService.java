package com.gymapp.demo.service;

import com.gymapp.demo.entity.Workout;
import com.gymapp.demo.repositories.WorkoutRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class WorkoutService {

    @Autowired
    private WorkoutRepository workoutRepository;

    public List<Workout> getWorkoutsByUserId(Long userId) {
        List<Workout> workouts = workoutRepository.findByUserId(userId);

        System.out.println("Retrieved workouts: " + workouts.size());  // Debugging line
        for (Workout workout : workouts) {
            System.out.println("Workout: " + workout);
        }

        return workouts;
    }
    public Optional<Workout> getWorkoutById(Long id) {
        return workoutRepository.findById(id);
    }

    public Workout saveWorkout(Workout workout) {
        return workoutRepository.save(workout);
    }

    public void deleteWorkout(Long id) {
        workoutRepository.deleteById(id);
    }
}