package com.gymapp.demo.controller;

import com.gymapp.demo.entity.Exercise;
import com.gymapp.demo.entity.Workout;
import com.gymapp.demo.repositories.WorkoutRepository;
import com.gymapp.demo.service.ExerciseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/exercises")
public class ExerciseController {
    @Autowired
    private ExerciseService exerciseService;

    @Autowired
    private WorkoutRepository workoutRepository;


    @GetMapping("/workout/{workoutId}")
    public List<Exercise> getExercisesByWorkoutId(@PathVariable Long workoutId) {
        return exerciseService.getExercisesByWorkoutId(workoutId);
    }

    @PostMapping
    public ResponseEntity<?> createExercise(@RequestBody Map<String, Object> requestBody) {
        if (!requestBody.containsKey("workoutId")) {
            return ResponseEntity.badRequest().body("Workout ID is required.");
        }

        Long workoutId = Long.valueOf(requestBody.get("workoutId").toString());
        Workout workout = workoutRepository.findById(workoutId)
                .orElseThrow(() -> new RuntimeException("Workout not found"));

        Exercise exercise = new Exercise();
        exercise.setWorkout(workout); // 👈 Set the actual Workout object
        exercise.setExerciseName(requestBody.get("exerciseName").toString());
        exercise.setSets(Integer.parseInt(requestBody.get("sets").toString()));
        exercise.setReps(Integer.parseInt(requestBody.get("reps").toString()));
        exercise.setWeight(Float.parseFloat(requestBody.get("weight").toString()));

        Exercise savedExercise = exerciseService.saveExercise(exercise);
        return ResponseEntity.ok(savedExercise);
    }
}