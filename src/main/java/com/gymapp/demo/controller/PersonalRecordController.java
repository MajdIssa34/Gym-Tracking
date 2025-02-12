package com.gymapp.demo.controller;

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

    @GetMapping("/user/{userId}")
    public List<PersonalRecord> getPersonalRecordsByUserId(@PathVariable Long userId) {
        return personalRecordService.getPersonalRecordsByUserId(userId);
    }

    @PostMapping
    public PersonalRecord createPersonalRecord(@RequestBody PersonalRecord personalRecord) {
        return personalRecordService.savePersonalRecord(personalRecord);
    }
}