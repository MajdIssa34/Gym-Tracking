package com.gymapp.demo.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@AllArgsConstructor
public class ProgressAnalyticsDTO {
    private String exerciseName;
    private float weight;
    private int sets;
    private int reps;
    private LocalDateTime createdAt;
}
