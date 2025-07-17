package com.learning.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.learning.dto.QuestionDetailDto;
import com.learning.model.Question;
import com.learning.repository.QuestionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class QuestionService {

    @Autowired
    private QuestionRepository questionRepository;

    private final ObjectMapper objectMapper = new ObjectMapper();

    public List<QuestionDetailDto> getQuestionDetailsByIds(List<UUID> questionIds) {
        List<Question> questions = questionRepository.findAllById(questionIds);
        return questions.stream()
                .map(this::mapQuestionToDto)
                .collect(Collectors.toList());
    }

    private QuestionDetailDto mapQuestionToDto(Question question) {
        QuestionDetailDto dto = new QuestionDetailDto();
        dto.setId(question.getId());
        dto.setQuestionText(question.getQuestionText());
        dto.setCorrectAnswer(question.getCorrectAnswer());
        dto.setExplanation(question.getExplanation());
        try {
            Map<String, String> optionsMap = objectMapper.readValue(question.getOptions(),
                    objectMapper.getTypeFactory().constructMapType(Map.class, String.class, String.class));
            dto.setOptions(optionsMap);
        } catch (JsonProcessingException e) {
            e.printStackTrace();
            // Handle error appropriately
        }
        return dto;
    }
}