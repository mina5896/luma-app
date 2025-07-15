package com.learning.model;

import jakarta.persistence.*;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "learning_objects")
public class LearningObject {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "topic_id", nullable = false)
    private Topic topic;

    @Column(nullable = false)
    private String title;

    private int difficulty;

    private int estTimeSeconds;

    @Column(columnDefinition = "TEXT")
    private String sourceUrl;

    @Column(nullable = false)
    private int learningOrder; // New field for ordering

    @ElementCollection
    @CollectionTable(name="learning_object_tags", joinColumns=@JoinColumn(name="owner_id"))
    private List<String> tags;

    @OneToMany(mappedBy = "learningObject", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("blockOrder ASC")
    private List<ContentBlock> contentBlocks;

    // --- Constructors ---
    public LearningObject() {
    }

    // --- Getters and Setters ---

    public int getLearningOrder() {
        return learningOrder;
    }

    public void setLearningOrder(int learningOrder) {
        this.learningOrder = learningOrder;
    }
    
    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public Topic getTopic() { return topic; }
    public void setTopic(Topic topic) { this.topic = topic; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public int getDifficulty() { return difficulty; }
    public void setDifficulty(int difficulty) { this.difficulty = difficulty; }
    public int getEstTimeSeconds() { return estTimeSeconds; }
    public void setEstTimeSeconds(int estTimeSeconds) { this.estTimeSeconds = estTimeSeconds; }
    public String getSourceUrl() { return sourceUrl; }
    public void setSourceUrl(String sourceUrl) { this.sourceUrl = sourceUrl; }
    public List<String> getTags() { return tags; }
    public void setTags(List<String> tags) { this.tags = tags; }
    public List<ContentBlock> getContentBlocks() { return contentBlocks; }
    public void setContentBlocks(List<ContentBlock> contentBlocks) { this.contentBlocks = contentBlocks; }
}