package com.gymapp.demo.controller;

import com.gymapp.demo.dto.CreateExerciseRequest;
import com.gymapp.demo.dto.ExerciseDTO;
import com.gymapp.demo.dto.ProgressAnalyticsDTO;
import com.gymapp.demo.entity.Exercise;
import com.gymapp.demo.entity.PersonalRecord;
import com.gymapp.demo.entity.ProgressAnalytics;
import com.gymapp.demo.entity.Workout;
import com.gymapp.demo.repositories.ExerciseRepository;
import com.gymapp.demo.repositories.PersonalRecordRepository;
import com.gymapp.demo.repositories.ProgressAnalyticsRepository;
import com.gymapp.demo.repositories.WorkoutRepository;
import com.gymapp.demo.service.ExerciseService;

import jakarta.transaction.Transactional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

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
        private ExerciseRepository exerciseRepository;

        @Autowired
        private PersonalRecordRepository personalRecordRepository;

        @Autowired
        private ProgressAnalyticsRepository progressAnalyticsRepository;

        @GetMapping("/workout/{workoutId}")
        public List<ExerciseDTO> getExercisesByWorkoutId(@PathVariable Long workoutId) {
                return exerciseService.getExercisesByWorkoutId(workoutId).stream()
                                .map(exercise -> new ExerciseDTO(
                                                exercise.getId(),
                                                exercise.getExerciseName(),
                                                exercise.getSets(),
                                                exercise.getReps(),
                                                exercise.getWeight(),
                                                exercise.getCreatedAt()))
                                .collect(Collectors.toList());
        }

        @GetMapping("/recent/{userId}")
        public List<ExerciseDTO> getRecentExercises(@PathVariable Long userId) {
                return exerciseService.getRecentExercises(userId).stream()
                                .map(exercise -> new ExerciseDTO(
                                                exercise.getId(),
                                                exercise.getExerciseName(),
                                                exercise.getSets(),
                                                exercise.getReps(),
                                                exercise.getWeight(),
                                                exercise.getCreatedAt()))
                                .collect(Collectors.toList());
        }

        /**
         * ✅ Get total sets, reps, and weight lifted in a workout.
         */
        /**
         * ✅ Get total sets, reps, and weight lifted in a workout.
         */
        @GetMapping("/workout/{workoutId}/summary")
        public ResponseEntity<?> getWorkoutSummary(@PathVariable Long workoutId) {
                List<Exercise> exercises = exerciseRepository.findByWorkoutId(workoutId);

                if (exercises.isEmpty()) {
                        return ResponseEntity.badRequest().body("No exercises found for this workout.");
                }

                int totalSets = exercises.stream().mapToInt(Exercise::getSets).sum();

                // Corrected: Multiply reps by sets to get total reps correctly
                int totalReps = exercises.stream().mapToInt(ex -> ex.getReps() * ex.getSets()).sum();

                float totalWeightLifted = (float) exercises.stream()
                                .mapToDouble(ex -> ex.getWeight() * ex.getReps() * ex.getSets())
                                .sum();

                return ResponseEntity.ok(new WorkoutSummaryResponse(totalSets, totalReps, totalWeightLifted));
        }

        /**
         * ✅ Create a new exercise (Also updates Progress Analytics & Personal Record).
         */
        @PostMapping
        public ResponseEntity<Exercise> createExercise(@RequestBody CreateExerciseRequest request) {
                if (request.getWorkoutId() == null) {
                        throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Workout ID is required.");
                }

                Workout workout = workoutRepository.findById(request.getWorkoutId())
                                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND,
                                                "Workout not found"));

                Exercise exercise = new Exercise(
                                workout,
                                request.getExerciseName(),
                                request.getSets(),
                                request.getReps(),
                                request.getWeight());

                // Save new exercise
                Exercise savedExercise = exerciseService.saveExercise(exercise);

                // ✅ Step 1: Update Progress Analytics (Log Every Workout)
                ProgressAnalytics progressAnalytics = new ProgressAnalytics(
                                workout.getUser(),
                                exercise.getExerciseName(),
                                exercise.getWeight(),
                                exercise.getSets(),
                                exercise.getReps());
                progressAnalyticsRepository.save(progressAnalytics);

                // ✅ Step 2: Check and Update Personal Record
                Optional<PersonalRecord> existingRecord = personalRecordRepository
                                .findTopByUserAndExerciseNameOrderByBestWeightDesc(
                                                workout.getUser(),
                                                exercise.getExerciseName());

                boolean isNewPR = false;
                if (existingRecord.isEmpty() ||
                                exercise.getWeight() > existingRecord.get().getBestWeight() ||
                                exercise.getReps() > existingRecord.get().getBestReps()) {

                        PersonalRecord newPR = new PersonalRecord(
                                        workout.getUser(),
                                        exercise.getExerciseName(),
                                        Math.max(existingRecord.map(PersonalRecord::getBestWeight).orElse(0.0f),
                                                        exercise.getWeight()),
                                        Math.max(existingRecord.map(PersonalRecord::getBestReps).orElse(0),
                                                        exercise.getReps()));
                        personalRecordRepository.save(newPR);
                        isNewPR = true;
                }

                // 🔹 Change this to return 201 Created
                return ResponseEntity.status(HttpStatus.CREATED).body(savedExercise);
        }

        @Transactional
        @DeleteMapping("/{exerciseId}")
        public ResponseEntity<?> deleteExercise(@PathVariable Long exerciseId) {
                Exercise exercise = exerciseRepository.findById(exerciseId)
                                .orElseThrow(() -> new ResponseStatusException(NOT_FOUND, "Exercise not found."));

                // Delete associated progress analytics records
                progressAnalyticsRepository.deleteByExerciseNameAndUserId(
                                exercise.getExerciseName(),
                                exercise.getWorkout().getUser().getId());

                // Delete associated personal record if it exists
                personalRecordRepository.deleteByExerciseNameAndUserId(
                                exercise.getExerciseName(),
                                exercise.getWorkout().getUser().getId());

                // Delete exercise itself
                exerciseRepository.delete(exercise);
                return ResponseEntity.ok("Exercise deleted successfully.");
        }

        @GetMapping("/progress/{userId}/{exerciseName}")
        public ResponseEntity<List<ProgressAnalyticsDTO>> getProgressByExercise(
                        @PathVariable Long userId,
                        @PathVariable String exerciseName) {
                List<ProgressAnalyticsDTO> progressList = progressAnalyticsRepository
                                .findByUserIdAndExerciseNameOrderByCreatedAtAsc(userId, exerciseName)
                                .stream()
                                .map(progress -> new ProgressAnalyticsDTO(
                                                progress.getExerciseName(),
                                                progress.getWeight(),
                                                progress.getSets(),
                                                progress.getReps(),
                                                progress.getCreatedAt()))
                                .collect(Collectors.toList());

                return ResponseEntity.ok(progressList);
        }

        // DTO for workout summary response
        static class WorkoutSummaryResponse {
                public int totalSets;
                public int totalReps;
                public float totalWeightLifted;

                public WorkoutSummaryResponse(int totalSets, int totalReps, float totalWeightLifted) {
                        this.totalSets = totalSets;
                        this.totalReps = totalReps;
                        this.totalWeightLifted = totalWeightLifted;
                }
        }
}
