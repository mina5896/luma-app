package com.learning.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.learning.dto.AssessmentQuestionDto;
import com.learning.dto.GeminiTextRequest;
import com.learning.dto.GeminiTextResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import java.io.IOException;
import java.util.List;

@Service
public class AssessmentService {

    private static final String ASSESSMENT_PROMPT_TEMPLATE = """
    **ROLE & GOAL:**
    You are an expert educator creating a placement test. Your goal is to generate a set of 10-15 multiple-choice questions to assess a user's initial knowledge of a given topic.

    **INSTRUCTIONS:**
    1.  The questions MUST cover a wide range of sub-topics, from fundamental to more advanced, to accurately gauge the user's proficiency level.
    2.  Your entire response MUST be **ONLY** a single, raw, valid JSON array of objects.
    3.  Each object in the array must have three keys: "questionText", "options" (a map of key-value pairs), and "correctAnswerKey".

    **EXAMPLE:**
    [
      {
        "questionText": "What does the 'static' keyword mean in Java?",
        "options": {
          "a": "The method can be changed.",
          "b": "The method belongs to the class, not an instance.",
          "c": "The method is final."
        },
        "correctAnswerKey": "b"
      }
    ]

    **TOPIC FOR ASSESSMENT:**
    %s
    """;

    @Autowired
    private RestTemplate restTemplate;

    @Value("${ai.api.key}")
    private String apiKey;
    @Value("${ai.api.url}")
    private String apiUrl;

    public List<AssessmentQuestionDto> generateAssessment(String topic) {
        String promptText = String.format(ASSESSMENT_PROMPT_TEMPLATE, topic);
        try {
            String jsonResponse = callAi(promptText);
            ObjectMapper objectMapper = new ObjectMapper();
            return objectMapper.readValue(jsonResponse, new TypeReference<List<AssessmentQuestionDto>>(){});
        } catch (IOException e) {
            e.printStackTrace();
            return List.of();
        }
    }
    
    private String callAi(String promptText) {
        // This helper method is identical to the one in CurriculumService
        GeminiTextRequest apiRequest = new GeminiTextRequest(promptText);
        String urlWithKey = apiUrl + "?key=" + apiKey;
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<GeminiTextRequest> entity = new HttpEntity<>(apiRequest, headers);
        GeminiTextResponse geminiResponse = restTemplate.postForObject(urlWithKey, entity, GeminiTextResponse.class);
        if (geminiResponse != null && !geminiResponse.getCandidates().isEmpty()) {
            String rawResponse = geminiResponse.getCandidates().get(0).getContent().getParts().get(0).getText();
            return rawResponse.trim().replace("```json", "").replace("```", "").trim();
        }
        return "[]"; // Return empty JSON array on failure
    }
}