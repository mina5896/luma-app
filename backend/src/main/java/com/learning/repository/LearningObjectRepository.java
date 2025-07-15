package com.learning.repository;

import com.learning.model.LearningObject;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface LearningObjectRepository extends JpaRepository<LearningObject, UUID> {

    // Spring Data JPA will automatically add "ORDER BY learning_order ASC" to the query
    List<LearningObject> findByTopicIdOrderByLearningOrderAsc(UUID topicId);

    // This will efficiently count the number of learning objectives for a given topic ID.
    long countByTopicId(UUID topicId);
}