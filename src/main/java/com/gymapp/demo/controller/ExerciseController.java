package com.gymapp.demo.controller;

import com.gymapp.demo.dto.CreateExerciseRequest;
import com.gymapp.demo.entity.Exercise;
import com.gymapp.demo.entity.Workout;
import com.gymapp.demo.repositories.WorkoutRepository;
import com.gymapp.demo.service.ExerciseService;
import lombok.Getter;
import lombok.Setter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

import static org.springframework.http.HttpStatus.BAD_REQUEST;
import static org.springframework.http.HttpStatus.NOT_FOUND;

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
    public ResponseEntity<Exercise> createExercise(@RequestBody CreateExerciseRequest request) {
        if (request.getWorkoutId() == null) {
            throw new ResponseStatusException(BAD_REQUEST, "Workout ID is required.");
        }

        Workout workout = workoutRepository.findById(request.getWorkoutId())
                .orElseThrow(() -> new ResponseStatusException(NOT_FOUND, "Workout not found"));

        Exercise exercise = new Exercise(
                workout,
                request.getExerciseName(),
                request.getSets(),
                request.getReps(),
                request.getWeight()
        );

        Exercise savedExercise = exerciseService.saveExercise(exercise);
        return ResponseEntity.ok(savedExercise);
    }
}
