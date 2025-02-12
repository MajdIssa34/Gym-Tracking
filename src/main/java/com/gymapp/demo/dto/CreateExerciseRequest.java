package com.gymapp.demo.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CreateExerciseRequest {
    private Long workoutId;
    private String exerciseName;
    private int sets;
    private int reps;
    private float weight;
}
