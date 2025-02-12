package com.gymapp.demo.controller;

import com.gymapp.demo.dto.CreateExerciseRequest;
import com.gymapp.demo.entity.Exercise;
import com.gymapp.demo.entity.PersonalRecord;
import com.gymapp.demo.entity.ProgressAnalytics;
import com.gymapp.demo.entity.Workout;
import com.gymapp.demo.repositories.PersonalRecordRepository;
import com.gymapp.demo.repositories.ProgressAnalyticsRepository;
import com.gymapp.demo.repositories.WorkoutRepository;
import com.gymapp.demo.service.ExerciseService;
import lombok.Getter;
import lombok.Setter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDate;
import java.util.Date;
import java.util.List;
import java.util.Optional;

import static org.springframework.http.HttpStatus.BAD_REQUEST;
import static org.springframework.http.HttpStatus.NOT_FOUND;

@RestController
@RequestMapping("/api/exercises")
public class ExerciseController {

    @Autowired
    private ExerciseService exerciseService;

    @Autowired
    private WorkoutRepository workoutRepository;

    @Autowired
    private PersonalRecordRepository personalRecordRepository;

    @Autowired
    private ProgressAnalyticsRepository progressAnalyticsRepository;

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

        // Save new exercise
        Exercise savedExercise = exerciseService.saveExercise(exercise);

        // ✅ Step 1: Update Progress Analytics (Log Every Workout)
        ProgressAnalytics progressAnalytics = new ProgressAnalytics(
                workout.getUser(),
                exercise.getExerciseName(),
                exercise.getWeight(),
                exercise.getSets(),
                exercise.getReps()
        );
        progressAnalyticsRepository.save(progressAnalytics);

        // Step 2: Check and Update Personal Record
        Optional<PersonalRecord> existingRecord = personalRecordRepository.findTopByUserAndExerciseNameOrderByBestWeightDesc(
                workout.getUser(),
                exercise.getExerciseName()
        );
        boolean isNewPR = false;
        if (existingRecord.isEmpty() ||
                exercise.getWeight() > existingRecord.get().getBestWeight() ||
                exercise.getReps() > existingRecord.get().getBestReps()) {

            PersonalRecord newPR = new PersonalRecord(
                    workout.getUser(),
                    exercise.getExerciseName(),
                    Math.max(existingRecord.map(PersonalRecord::getBestWeight).orElse(0.0f), exercise.getWeight()),
                    Math.max(existingRecord.map(PersonalRecord::getBestReps).orElse(0), exercise.getReps())
            );
            personalRecordRepository.save(newPR);
            isNewPR = true;
        }

        return ResponseEntity.ok(savedExercise);
    }
}
