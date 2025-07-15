package com.learning.dto;

import java.util.UUID;

public class LearningObjectiveSummaryDto {
    private UUID id;
    private String title;
    private int difficulty;

    // --- Constructors, Getters, and Setters ---
    public LearningObjectiveSummaryDto(UUID id, String title, int difficulty) {
        this.id = id;
        this.title = title;
        this.difficulty = difficulty;
    }

    public UUID getId() {
        return id;
    }
    public void setId(UUID id) {
        this.id = id;
    }
    public String getTitle() {
        return title;
    }
    public void setTitle(String title) {
        this.title = title;
    }
    public int getDifficulty() {
        return difficulty;
    }
    public void setDifficulty(int difficulty) {
        this.difficulty = difficulty;
    }
}