package com.gymapp.demo.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

@Getter
@Setter
@AllArgsConstructor
public class WorkoutDTO {
    private Long id;
    private String notes;
    private LocalDate createdAt;
}
