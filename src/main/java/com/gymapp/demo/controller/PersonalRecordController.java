package com.gymapp.demo.controller;

import com.gymapp.demo.dto.PRDTO;
import com.gymapp.demo.entity.PersonalRecord;
import com.gymapp.demo.service.PersonalRecordService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/personal-records")
public class PersonalRecordController {
    @Autowired
    private PersonalRecordService personalRecordService;

    // ✅ Get only the best personal records per exercise
    @GetMapping("/user/{userId}")
    public List<PRDTO> getBestPersonalRecordsByUserId(@PathVariable Long userId) {
        return personalRecordService.getPersonalRecordsByUserId(userId);
    }
}
