package com.gymapp.demo.controller;

import com.gymapp.demo.dto.WorkoutDTO;
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
    public List<WorkoutDTO> getWorkoutsByUserId(@PathVariable Long userId) {
        return workoutService.getWorkoutsByUserId(userId);
    }

    @PostMapping
    public ResponseEntity<WorkoutDTO> createWorkout(@RequestBody Workout workout) {
        if (workout.getUser() == null || workout.getUser().getId() == null) {
            return ResponseEntity.badRequest().build();
        }

        User user = userRepository.findById(workout.getUser().getId())
                .orElseThrow(() -> new RuntimeException("User not found"));

        workout.setUser(user); // Set user before saving

        Workout savedWorkout = workoutService.saveWorkout(workout);

        // ✅ Return only essential fields via WorkoutDTO
        WorkoutDTO responseDTO = new WorkoutDTO(
                savedWorkout.getId(),
                savedWorkout.getNotes(),
                savedWorkout.getCreatedAt()
        );

        return ResponseEntity.ok(responseDTO);
    }

}