package com.gymapp.demo.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
@Table(name = "exercises")
public class Exercise {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "workout_id", nullable = false) // Matches SQL foreign key
    private Workout workout;

    @Column(name = "exercise_name", nullable = false) // Matches SQL column name
    private String exerciseName;

    @Column(nullable = false)
    private int sets;

    @Column(nullable = false)
    private int reps;

    @Column(nullable = false)
    private float weight;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "created_at", updatable = false, nullable = false)
    private java.util.Date createdAt = new java.util.Date();

    public Exercise() {}

    public Exercise(Workout workout, String exerciseName, int sets, int reps, float weight) {
        this.workout = workout;
        this.exerciseName = exerciseName;
        this.sets = sets;
        this.reps = reps;
        this.weight = weight;
        this.createdAt = new java.util.Date();
    }
}
