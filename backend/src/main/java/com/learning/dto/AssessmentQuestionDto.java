package com.learning.dto;

import java.util.Map;

public class AssessmentQuestionDto {
    private String questionText;
    private Map<String, String> options;
    private String correctAnswerKey;

    // Getters and Setters...
    public String getQuestionText() { return questionText; }
    public void setQuestionText(String questionText) { this.questionText = questionText; }
    public Map<String, String> getOptions() { return options; }
    public void setOptions(Map<String, String> options) { this.options = options; }
    public String getCorrectAnswerKey() { return correctAnswerKey; }
    public void setCorrectAnswerKey(String correctAnswerKey) { this.correctAnswerKey = correctAnswerKey; }
}