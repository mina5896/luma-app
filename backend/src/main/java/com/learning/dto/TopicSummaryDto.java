package com.learning.dto;

import com.learning.model.TopicStatus; // Import the enum
import java.util.UUID;

public class TopicSummaryDto {
    private UUID id;
    private String name;
    private String description;
    private String category;
    private String imageUrl;
    private long totalObjectives;
    private TopicStatus status; // The new field

    // --- Constructors ---
    public TopicSummaryDto() {
    }

    public TopicSummaryDto(UUID id, String name, String description, String category, String imageUrl, long totalObjectives, TopicStatus status) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.category = category;
        this.imageUrl = imageUrl;
        this.totalObjectives = totalObjectives;
        this.status = status; // Add to constructor
    }
    
    // --- Getters and Setters ---
    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    public long getTotalObjectives() { return totalObjectives; }
    public void setTotalObjectives(long totalObjectives) { this.totalObjectives = totalObjectives; }
    public TopicStatus getStatus() { return status; }
    public void setStatus(TopicStatus status) { this.status = status; }
}