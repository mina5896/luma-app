package com.learning.repository;

import com.learning.model.Question;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List; // Import List
import java.util.UUID;

@Repository
public interface QuestionRepository extends JpaRepository<Question, UUID> {

    // Finds all questions for a specific content block (micro-quiz)
    List<Question> findByContentBlockId(UUID contentBlockId);

    // Finds all questions for a specific learning object (final quiz)
    List<Question> findByLearningObjectId(UUID learningObjectId);
}