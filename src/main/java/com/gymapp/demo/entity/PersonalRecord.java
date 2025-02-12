package com.gymapp.demo.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.Date;

@Entity
@Getter
@Setter
@Table(name = "personal_records")
public class PersonalRecord {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "client_id", nullable = false) // Matches SQL schema
    private User client;

    @Column(name = "exercise_name", nullable = false)
    private String exerciseName;

    @Column(name = "best_weight", nullable = false)
    private float bestWeight;

    @Column(name = "best_reps", nullable = false)
    private int bestReps;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "created_at", updatable = false, nullable = false)
    private Date createdAt = new Date();

    public PersonalRecord() {}

    public PersonalRecord(User client, String exerciseName, float bestWeight, int bestReps) {
        this.client = client;
        this.exerciseName = exerciseName;
        this.bestWeight = bestWeight;
        this.bestReps = bestReps;
        this.createdAt = new Date();
    }
}
