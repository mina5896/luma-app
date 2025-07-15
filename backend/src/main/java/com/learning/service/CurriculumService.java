package com.learning.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.learning.dto.CurriculumDto;
import com.learning.dto.GeminiTextRequest;
import com.learning.dto.GeminiTextResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.io.IOException;

@Service
public class CurriculumService {

    private static final String AI_CURRICULUM_PROMPT_TEMPLATE = """
    **ROLE & GOAL:**
    You are an expert curriculum planner. Your task is to generate a complete topic overview, including a category, description, and a list of specific learning objectives.

    **INSTRUCTIONS:**
    1.  Determine a single, broad category for the topic (e.g., "Programming", "History", "Science").
    2.  Write a concise, engaging description for the overall topic (2-3 sentences).
    3.  Provide a direct, functional image URL from a free stock photo website like Pexels or Unsplash.
    4.  Create a list of 12 to 15 distinct, beginner-friendly learning objective titles. The list MUST be in a logical, sequential order that builds from simple to complex.
    5.  All titles MUST be in Title Case (e.g., "What Is a Java Variable?").
    6.  Your entire response MUST be **ONLY** a single, raw, valid JSON object.

    **EXAMPLE:**
    {
      "category": "Programming",
      "description": "An introduction to the fundamentals of the Java language...",
      "image_url": "https://images.pexels.com/photos/1181244/pexels-photo-1181244.jpeg",
      "learning_objectives": ["What Is Java?", "Understanding Variables and Data Types", "Exploring Basic Operators"]
    }

    **TOPIC TO PLAN:**
    %s
    """;

    @Autowired
    private RestTemplate restTemplate;

    @Value("${ai.api.key}")
    private String apiKey;
    @Value("${ai.api.url}")
    private String apiUrl;

    public CurriculumDto generateCurriculum(String topicName) {
        System.out.println("Generating full curriculum and topic details for: " + topicName);
        String promptText = String.format(AI_CURRICULUM_PROMPT_TEMPLATE, topicName);
        
        try {
            String jsonResponse = callAi(promptText);
            ObjectMapper objectMapper = new ObjectMapper();
            return objectMapper.readValue(jsonResponse, CurriculumDto.class);
        } catch (IOException e) {
            System.err.println("Error generating curriculum for topic: " + topicName);
            e.printStackTrace();
        }
        return null;
    }

    private String callAi(String promptText) {
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
        return "{}";
    }
}