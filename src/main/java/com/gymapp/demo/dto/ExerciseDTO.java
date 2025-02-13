package com.gymapp.demo.dto;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class ExerciseDTO {
    private Long id;
    private String exerciseName;
    private int sets;
    private int reps;
    private float weight;
    private LocalDateTime createdAt;

    public ExerciseDTO(Long id, String exerciseName, int sets, int reps, float weight, LocalDateTime createdAt) {
        this.id = id;
        this.exerciseName = exerciseName;
        this.sets = sets;
        this.reps = reps;
        this.weight = weight;
        this.createdAt = createdAt;
    }

    // Getters
    public Long getId() { return id; }
    public String getExerciseName() { return exerciseName; }
    public int getSets() { return sets; }
    public int getReps() { return reps; }
    public float getWeight() { return weight; }
    public LocalDateTime getCreatedAt() { return createdAt; }
}
