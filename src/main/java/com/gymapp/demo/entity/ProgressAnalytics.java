package com.gymapp.demo.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@Table(name = "progress_analytics")
public class ProgressAnalytics {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false) // FIXED: Matches SQL schema
    private User user;  // Renamed from 'client' to 'user'

    @Column(name = "exercise_name", nullable = false)
    private String exerciseName;

    @Column(name = "weight", nullable = false)
    private float weight;

    @Column(name = "sets", nullable = false)
    private int sets;

    @Column(name = "reps", nullable = false)
    private int reps;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false, nullable = false)
    private LocalDateTime createdAt; // FIXED: Use LocalDateTime with @CreationTimestamp

    public ProgressAnalytics() {}

    public ProgressAnalytics(User user, String exerciseName, float weight, int sets, int reps) {
        this.user = user;
        this.exerciseName = exerciseName;
        this.weight = weight;
        this.sets = sets;
        this.reps = reps;
    }
}
