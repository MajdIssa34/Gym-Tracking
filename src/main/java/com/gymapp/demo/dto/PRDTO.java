package com.gymapp.demo.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class PRDTO {
    private String exerciseName;
    private float bestWeight;
    private int bestReps;
}
