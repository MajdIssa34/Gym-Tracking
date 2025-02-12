package com.gymapp.demo.service;

import com.gymapp.demo.dto.WorkoutDTO;
import com.gymapp.demo.entity.Workout;
import com.gymapp.demo.repositories.WorkoutRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class WorkoutService {

    @Autowired
    private WorkoutRepository workoutRepository;

    public List<WorkoutDTO> getWorkoutsByUserId(Long userId) {
        List<Workout> workouts = workoutRepository.findByUserId(userId);

        return workouts.stream()
                .map(workout -> new WorkoutDTO(
                        workout.getId(),
                        workout.getNotes(),
                        workout.getCreatedAt()
                ))
                .collect(Collectors.toList());
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