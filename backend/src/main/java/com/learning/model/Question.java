package com.learning.model;

import jakarta.persistence.*;
import java.util.UUID;

@Entity
@Table(name = "questions")
public class Question {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;

    // For micro-quizzes after a specific lesson block
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "content_block_id") // Can be null
    private ContentBlock contentBlock;

    // For the final quiz of a learning object
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "learning_object_id") // Can be null
    private LearningObject learningObject;

    @Column(columnDefinition = "TEXT", nullable = false)
    private String questionText;
    
    @Column(columnDefinition = "TEXT")
    private String options;

    @Column(nullable = false)
    private String correctAnswer;

    @Column(columnDefinition = "TEXT")
    private String explanation;

    // --- Constructors ---
    public Question() {
    }

    // --- Getters and Setters ---
    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public ContentBlock getContentBlock() {
        return contentBlock;
    }

    public void setContentBlock(ContentBlock contentBlock) {
        this.contentBlock = contentBlock;
    }

    public LearningObject getLearningObject() {
        return learningObject;
    }

    public void setLearningObject(LearningObject learningObject) {
        this.learningObject = learningObject;
    }

    public String getQuestionText() {
        return questionText;
    }

    public void setQuestionText(String questionText) {
        this.questionText = questionText;
    }

    public String getOptions() {
        return options;
    }

    public void setOptions(String options) {
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