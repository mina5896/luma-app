package com.learning.model;

import jakarta.persistence.*; // Import EnumType and Enumerated
import java.util.UUID;

@Entity
@Table(name = "topics")
public class Topic {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;

    private String name;

    // --- ADD THIS ANNOTATION ---
    @Column(columnDefinition = "TEXT")
    private String description;

    private String category;

    // --- AND ADD THIS ANNOTATION ---
    @Column(columnDefinition = "TEXT")
    private String imageUrl;

    @Enumerated(EnumType.STRING)
    private TopicStatus status;

    // --- Constructors, Getters, and Setters remain the same ---

    public Topic() {
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public TopicStatus getStatus() {
        return status;
    }
    public void setStatus(TopicStatus status) {
        this.status = status;
    }
}