package com.gymapp.demo.entity;

import lombok.Getter;
import lombok.Setter;
import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;

import java.util.Date;

@Entity
@Table(name = "workouts")
@Getter
@Setter
public class Workout {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "client_id", nullable = false)  // Matches SQL schema
    private User client;  // Changed from 'user' to 'client' for clarity

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "created_at", updatable = false, nullable = false)
    @CreationTimestamp
    private Date createdAt = new Date();

    @Temporal(TemporalType.DATE)
    @Column(name = "date", nullable = false)
    private Date date;

    @Column(columnDefinition = "TEXT")
    private String notes;

    public Workout() {}

    public Workout(User client, Date date, String notes) {
        this.client = client;
        this.date = date;
        this.notes = notes;
        this.createdAt = new Date();
    }
}
