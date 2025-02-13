package com.gymapp.demo.service;

import com.gymapp.demo.dto.PRDTO;
import com.gymapp.demo.entity.PersonalRecord;
import com.gymapp.demo.repositories.PersonalRecordRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class PersonalRecordService {

    @Autowired
    private PersonalRecordRepository personalRecordRepository;

    public List<PRDTO> getPersonalRecordsByUserId(Long userId) {
        List<PersonalRecord> records = personalRecordRepository.findBestRecordsByUserId(userId);
        return records.stream()
                .map(record -> new PRDTO(record.getExerciseName(), record.getBestWeight(), record.getBestReps()))
                .collect(Collectors.toList());
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
