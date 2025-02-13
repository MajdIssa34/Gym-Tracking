package com.gymapp.demo.repositories;

import com.gymapp.demo.entity.PersonalRecord;
import com.gymapp.demo.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PersonalRecordRepository extends JpaRepository<PersonalRecord, Long> {
    @Query("SELECT pr FROM PersonalRecord pr WHERE pr.user.id = :userId " +
            "AND pr.bestWeight = (SELECT MAX(pr2.bestWeight) FROM PersonalRecord pr2 WHERE pr2.user.id = :userId AND pr2.exerciseName = pr.exerciseName)")
    List<PersonalRecord> findBestRecordsByUserId(Long userId);
    List<PersonalRecord> findByExerciseName(String exerciseName);
    Optional<PersonalRecord> findTopByUserAndExerciseNameOrderByBestWeightDesc(User user, String exerciseName);
    @Query("SELECT pr FROM PersonalRecord pr " +
            "WHERE pr.user.id = :userId " +
            "AND pr.bestWeight = (SELECT MAX(p.bestWeight) FROM PersonalRecord p WHERE p.user.id = :userId AND p.exerciseName = pr.exerciseName)")
    List<PersonalRecord> findTopRecordsByUserId(@Param("userId") Long userId);
    void deleteByExerciseNameAndUserId(String exerciseName, Long userId);

}