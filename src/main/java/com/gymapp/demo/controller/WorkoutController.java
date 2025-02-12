package com.gymapp.demo.controller;

import com.gymapp.demo.entity.User;
import com.gymapp.demo.entity.Workout;
import com.gymapp.demo.repositories.UserRepository;
import com.gymapp.demo.service.WorkoutService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/workouts")
public class WorkoutController {
    @Autowired
    private WorkoutService workoutService;

    @Autowired
    private UserRepository userRepository;

    @GetMapping("/user/{userId}")
    public List<Workout> getWorkoutsByUserId(@PathVariable Long userId) {
        return workoutService.getWorkoutsByUserId(userId);
    }

    @PostMapping
    public ResponseEntity<?> createWorkout(@RequestBody Workout workout) {
        if (workout.getClient() == null || workout.getClient().getId() == null) {
            return ResponseEntity.badRequest().body("User ID is required.");
        }

        User user = userRepository.findById(workout.getClient().getId())
                .orElseThrow(() -> new RuntimeException("User not found"));

        workout.setClient(user); // 👈 Set the fetched User object before saving
        Workout savedWorkout = workoutService.saveWorkout(workout);

        return ResponseEntity.ok(savedWorkout);
    }
}