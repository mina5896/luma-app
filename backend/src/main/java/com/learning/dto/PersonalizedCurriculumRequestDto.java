package com.learning.dto;

import java.util.List;
import java.util.Map;

public class PersonalizedCurriculumRequestDto {
    private String topic;
    private List<Map<String, String>> userAnswers; // e.g., [{"question": "...", "selectedAnswerKey": "b"}]

    // Getters and Setters...
    public String getTopic() { return topic; }
    public void setTopic(String topic) { this.topic = topic; }
    public List<Map<String, String>> getUserAnswers() { return userAnswers; }
    public void setUserAnswers(List<Map<String, String>> userAnswers) { this.userAnswers = userAnswers; }
}