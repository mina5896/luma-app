package com.learning.dto;

import java.util.List;
import java.util.UUID;

public class TopicDetailDto {
    private UUID id;
    private String name;
    private String description;
    private List<LearningObjectiveSummaryDto> learningObjectives;

    // --- Constructors, Getters, and Setters ---
    public TopicDetailDto(UUID id, String name, String description, List<LearningObjectiveSummaryDto> learningObjectives) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.learningObjectives = learningObjectives;
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
    public List<LearningObjectiveSummaryDto> getLearningObjectives() {
        return learningObjectives;
    }
    public void setLearningObjectives(List<LearningObjectiveSummaryDto> learningObjectives) {
        this.learningObjectives = learningObjectives;
    }
}