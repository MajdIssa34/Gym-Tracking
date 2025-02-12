package com.gymapp.demo.repositories;

import com.gymapp.demo.entity.PersonalRecord;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PersonalRecordRepository extends JpaRepository<PersonalRecord, Long> {
    List<PersonalRecord> findByUserId(Long userId);
    List<PersonalRecord> findByExerciseName(String exerciseName);
}