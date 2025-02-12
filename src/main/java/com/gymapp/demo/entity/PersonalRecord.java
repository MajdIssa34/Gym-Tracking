package com.gymapp.demo.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@Table(name = "personal_records")
public class PersonalRecord {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false) // FIXED: Matches SQL schema
    private User user;  // Renamed from 'client' to 'user'

    @Column(name = "exercise_name", nullable = false)
    private String exerciseName;

    @Column(name = "best_weight", nullable = false)
    private float bestWeight;

    @Column(name = "best_reps", nullable = false)
    private int bestReps;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false, nullable = false)
    private LocalDateTime createdAt; // FIXED: Use LocalDateTime with @CreationTimestamp

    public PersonalRecord() {}

    public PersonalRecord(User user, String exerciseName, float bestWeight, int bestReps) {
        this.user = user;
        this.exerciseName = exerciseName;
        this.bestWeight = bestWeight;
        this.bestReps = bestReps;
    }
}
