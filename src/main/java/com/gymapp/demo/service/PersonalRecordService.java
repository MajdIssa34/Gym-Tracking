package com.gymapp.demo.service;

import com.gymapp.demo.entity.PersonalRecord;
import com.gymapp.demo.repositories.PersonalRecordRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class PersonalRecordService {

    @Autowired
    private PersonalRecordRepository personalRecordRepository;

    public List<PersonalRecord> getPersonalRecordsByUserId(Long userId) {
        return personalRecordRepository.findByUserId(userId);
    }

    public List<PersonalRecord> getPersonalRecordsByExerciseName(String exerciseName) {
        return personalRecordRepository.findByExerciseName(exerciseName);
    }

    public PersonalRecord savePersonalRecord(PersonalRecord personalRecord) {
        return personalRecordRepository.save(personalRecord);
    }

    public void deletePersonalRecord(Long id) {
        personalRecordRepository.deleteById(id);
    }
}
