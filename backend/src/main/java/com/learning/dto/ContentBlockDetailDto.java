package com.learning.dto;

import com.learning.model.BlockType;
import java.util.List;
import java.util.UUID;

public class ContentBlockDetailDto {
    private UUID id;
    private int blockOrder;
    private BlockType blockType;
    private String contentPayload;
    private List<QuestionDetailDto> questions;

    // --- Constructors ---
    public ContentBlockDetailDto() {
    }

    public ContentBlockDetailDto(UUID id, int blockOrder, BlockType blockType, String contentPayload, List<QuestionDetailDto> questions) {
        this.id = id;
        this.blockOrder = blockOrder;
        this.blockType = blockType;
        this.contentPayload = contentPayload;
        this.questions = questions;
    }

    // --- Getters and Setters ---
    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public int getBlockOrder() {
        return blockOrder;
    }

    public void setBlockOrder(int blockOrder) {
        this.blockOrder = blockOrder;
    }

    public BlockType getBlockType() {
        return blockType;
    }

    public void setBlockType(BlockType blockType) {
        this.blockType = blockType;
    }

    public String getContentPayload() {
        return contentPayload;
    }

    public void setContentPayload(String contentPayload) {
        this.contentPayload = contentPayload;
    }

    public List<QuestionDetailDto> getQuestions() {
        return questions;
    }

    public void setQuestions(List<QuestionDetailDto> questions) {
        this.questions = questions;
    }
}