package com.learning.dto;

import java.util.List;
import java.util.UUID;

public class LearningObjectiveDetailDto {
    private UUID id;
    private String title;
    private List<ContentBlockDetailDto> contentBlocks;
    private List<QuestionDetailDto> finalQuizQuestions;

    // --- Constructors ---
    public LearningObjectiveDetailDto() {
    }

    public LearningObjectiveDetailDto(UUID id, String title, List<ContentBlockDetailDto> contentBlocks, List<QuestionDetailDto> finalQuizQuestions) {
        this.id = id;
        this.title = title;
        this.contentBlocks = contentBlocks;
        this.finalQuizQuestions = finalQuizQuestions;
    }

    // --- Getters and Setters ---
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

    public List<ContentBlockDetailDto> getContentBlocks() {
        return contentBlocks;
    }

    public void setContentBlocks(List<ContentBlockDetailDto> contentBlocks) {
        this.contentBlocks = contentBlocks;
    }

    public List<QuestionDetailDto> getFinalQuizQuestions() {
        return finalQuizQuestions;
    }

    public void setFinalQuizQuestions(List<QuestionDetailDto> finalQuizQuestions) {
        this.finalQuizQuestions = finalQuizQuestions;
    }
}