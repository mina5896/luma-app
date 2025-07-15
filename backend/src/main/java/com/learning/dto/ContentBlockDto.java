package com.learning.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.learning.model.BlockType;
import java.util.List;

@JsonIgnoreProperties(ignoreUnknown = true)
public class ContentBlockDto {

    private BlockType block_type;
    private String content;
    private List<QuestionDTO> questions;

    // --- Getters and Setters ---
    public BlockType getBlock_type() {
        return block_type;
    }
    public void setBlock_type(BlockType block_type) {
        this.block_type = block_type;
    }
    public String getContent() {
        return content;
    }
    public void setContent(String content) {
        this.content = content;
    }
    public List<QuestionDTO> getQuestions() {
        return questions;
    }
    public void setQuestions(List<QuestionDTO> questions) {
        this.questions = questions;
    }
}