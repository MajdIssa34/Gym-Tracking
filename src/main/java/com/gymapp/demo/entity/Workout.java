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
    @JoinColumn(name = "user_id", nullable = false)  // FIXED: Changed to match SQL schema
    private User user;  // FIXED: Renamed from 'client' to 'user'

    @Temporal(TemporalType.TIMESTAMP)
    @Column(name = "created_at", updatable = false, nullable = false)
    @CreationTimestamp
    private Date createdAt;

    public Workout() {}

    public Workout(User user) {
        this.user = user;
        this.createdAt = new Date();
    }
}
