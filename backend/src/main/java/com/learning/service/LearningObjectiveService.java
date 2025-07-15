package com.learning.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.learning.dto.ContentBlockDetailDto;
import com.learning.dto.LearningObjectiveDetailDto;
import com.learning.dto.QuestionDetailDto;
import com.learning.model.ContentBlock;
import com.learning.model.LearningObject;
import com.learning.model.Question;
import com.learning.repository.LearningObjectRepository;
import com.learning.repository.QuestionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class LearningObjectiveService {

    @Autowired
    private LearningObjectRepository learningObjectRepository;

    @Autowired
    private QuestionRepository questionRepository;

    private final ObjectMapper objectMapper = new ObjectMapper();

    public LearningObjectiveDetailDto getLearningObjectiveDetails(UUID objectiveId) {
        LearningObject lo = learningObjectRepository.findById(objectiveId)
                .orElseThrow(() -> new RuntimeException("LearningObjective not found with id: " + objectiveId));

        // Map ContentBlocks to DTOs, including their specific questions
        List<ContentBlockDetailDto> contentBlockDtos = lo.getContentBlocks().stream()
                .map(this::mapContentBlockToDto)
                .collect(Collectors.toList());

        // Get the final quiz questions for the entire learning objective
        List<Question> finalQuizEntities = questionRepository.findByLearningObjectId(objectiveId);
        List<QuestionDetailDto> finalQuizDtos = finalQuizEntities.stream()
                .map(this::mapQuestionToDto)
                .collect(Collectors.toList());

        return new LearningObjectiveDetailDto(lo.getId(), lo.getTitle(), contentBlockDtos, finalQuizDtos);
    }

    private ContentBlockDetailDto mapContentBlockToDto(ContentBlock block) {
        List<Question> questionEntities = questionRepository.findByContentBlockId(block.getId());
        List<QuestionDetailDto> questionDtos = questionEntities.stream()
                .map(this::mapQuestionToDto)
                .collect(Collectors.toList());
        return new ContentBlockDetailDto(block.getId(), block.getBlockOrder(), block.getBlockType(), block.getContentPayload(), questionDtos);
    }

    private QuestionDetailDto mapQuestionToDto(Question question) {
        try {
            Map<String, String> optionsMap = objectMapper.readValue(question.getOptions(),
                    objectMapper.getTypeFactory().constructMapType(Map.class, String.class, String.class));
            return new QuestionDetailDto(question.getId(), question.getQuestionText(), optionsMap, question.getCorrectAnswer(), question.getExplanation());
        } catch (JsonProcessingException e) {
            throw new RuntimeException("Failed to parse question options", e);
        }
    }
}