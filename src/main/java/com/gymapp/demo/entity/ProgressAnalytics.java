package com.gymapp.demo.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.Date;

@Entity
@Getter
@Setter
@Table(name = "progress_analytics")
public class ProgressAnalytics {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "client_id", nullable = false) // Matches SQL schema
    private User client;

    @Column(name = "exercise_name", nullable = false)
    private String exerciseName;

    @Temporal(TemporalType.DATE)
    @Column(name = "date", nullable = false)
    private Date date;

    @Column(name = "weight", nullable = false)
    private float weight;

    @Column(name = "sets", nullable = false)
    private int sets;

    @Column(name = "reps", nullable = false)
    private int reps;

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "created_at", updatable = false, nullable = false)
    private Date createdAt = new Date();

    public ProgressAnalytics() {}

    public ProgressAnalytics(User client, String exerciseName, Date date, float weight, int sets, int reps) {
        this.client = client;
        this.exerciseName = exerciseName;
        this.date = date;
        this.weight = weight;
        this.sets = sets;
        this.reps = reps;
        this.createdAt = new Date();
    }
}
