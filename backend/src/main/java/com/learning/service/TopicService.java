package com.learning.service;

import com.learning.dto.LearningObjectiveSummaryDto;
import com.learning.dto.TopicDetailDto;
import com.learning.dto.TopicSummaryDto; // Import the new DTO
import com.learning.model.LearningObject;
import com.learning.model.Topic;
import com.learning.repository.LearningObjectRepository;
import com.learning.repository.TopicRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class TopicService {

    @Autowired
    private TopicRepository topicRepository;

    @Autowired
    private LearningObjectRepository learningObjectRepository;

    // --- NEW METHOD TO GET SUMMARIES WITH PROGRESS ---
    public List<TopicSummaryDto> getTopicSummaries() {
        System.out.println("I AM HERE-------------");
        List<Topic> topics = topicRepository.findAll();

        return topics.stream().map(topic -> {
            long totalObjectives = learningObjectRepository.countByTopicId(topic.getId());
            return new TopicSummaryDto(
                    topic.getId(),
                    topic.getName(),
                    topic.getDescription(),
                    topic.getCategory(),
                    topic.getImageUrl(),
                    totalObjectives);
        }).collect(Collectors.toList());
    }

    public TopicDetailDto getTopicDetails(UUID topicId) {
        Topic topic = topicRepository.findById(topicId)
                .orElseThrow(() -> new RuntimeException("Topic not found with id: " + topicId));

        List<LearningObject> learningObjects = learningObjectRepository.findByTopicIdOrderByLearningOrderAsc(topicId);

        List<LearningObjectiveSummaryDto> summaryDtos = learningObjects.stream()
                .map(lo -> new LearningObjectiveSummaryDto(lo.getId(), lo.getTitle(), lo.getDifficulty()))
                .collect(Collectors.toList());

        return new TopicDetailDto(topic.getId(), topic.getName(), topic.getDescription(), summaryDtos);
    }
}