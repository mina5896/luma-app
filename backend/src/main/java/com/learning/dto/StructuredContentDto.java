package com.learning.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import java.util.List;

@JsonIgnoreProperties(ignoreUnknown = true)
public class StructuredContentDto {

    private String title;
    private int difficulty;
    private List<String> tags;
    private List<ContentBlockDto> content_blocks;
    private List<QuestionDTO> final_quiz_questions;

    // --- Getters and Setters ---
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
    public List<String> getTags() {
        return tags;
    }
    public void setTags(List<String> tags) {
        this.tags = tags;
    }
    public List<ContentBlockDto> getContent_blocks() {
        return content_blocks;
    }
    public void setContent_blocks(List<ContentBlockDto> content_blocks) {
        this.content_blocks = content_blocks;
    }
    public List<QuestionDTO> getFinal_quiz_questions() {
        return final_quiz_questions;
    }
    public void setFinal_quiz_questions(List<QuestionDTO> final_quiz_questions) {
        this.final_quiz_questions = final_quiz_questions;
    }
}