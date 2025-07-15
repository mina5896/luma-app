package com.learning.repository;

import com.learning.model.Topic;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional; // Make sure to import Optional
import java.util.UUID;

@Repository
public interface TopicRepository extends JpaRepository<Topic, UUID> {

    /**
     * Finds a Topic by its unique name. Spring Data JPA automatically
     * implements this method based on its name.
     * @param name The name of the topic to find.
     * @return An Optional containing the Topic if found, or an empty Optional otherwise.
     */
    Optional<Topic> findByName(String name); // Add this line

}