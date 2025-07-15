package com.learning.dto;

import java.util.Map;
import java.util.UUID;

public class QuestionDetailDto {
    private UUID id;
    private String questionText;
    private Map<String, String> options;
    private String correctAnswer;
    private String explanation;

    // --- Constructors ---
    public QuestionDetailDto() {
    }

    public QuestionDetailDto(UUID id, String questionText, Map<String, String> options, String correctAnswer, String explanation) {
        this.id = id;
        this.questionText = questionText;
        this.options = options;
        this.correctAnswer = correctAnswer;
        this.explanation = explanation;
    }

    // --- Getters and Setters ---
    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getQuestionText() {
        return questionText;
    }

    public void setQuestionText(String questionText) {
        this.questionText = questionText;
    }

    public Map<String, String> getOptions() {
        return options;
    }

    public void setOptions(Map<String, String> options) {
        this.options = options;
    }

    public String getCorrectAnswer() {
        return correctAnswer;
    }

    public void setCorrectAnswer(String correctAnswer) {
        this.correctAnswer = correctAnswer;
    }

    public String getExplanation() {
        return explanation;
    }

    public void setExplanation(String explanation) {
        this.explanation = explanation;
    }
}