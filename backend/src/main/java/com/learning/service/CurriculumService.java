package com.learning.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.learning.dto.CurriculumDto;
import com.learning.dto.GeminiTextRequest;
import com.learning.dto.GeminiTextResponse;
import com.learning.model.Topic;
import com.learning.model.TopicStatus;
import com.learning.repository.TopicRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

@Service
public class CurriculumService {

    // --- UPDATED PROMPT WITH AN EXAMPLE ---
     private static final String AI_GENERIC_CURRICULUM_PROMPT = """
    **ROLE & GOAL:**
    You are an expert curriculum planner creating a general learning path for a user.

    **USER CONTEXT:**
    * **Topic:** %s

    **INSTRUCTIONS:**
    1.  Generate a curriculum of 12-15 logically sequenced learning objective titles in Title Case. You MUST generate a list of exactly 12 to 15 logically sequenced learning objective titles. Do not generate more or less.
    2.  The curriculum MUST start with a brief review of fundamentals but then **focus heavily on the user's identified weak areas**.
    3.  You must stay on topic and avoid introducing unrelated concepts.
    4.  The category field should be a single, broad category (e.g., "Programming", "History", "Science").
    5.  Write a concise, engaging description for the overall topic (2-3 sentences).
    6.  Provide a direct, functional image URL from a free stock photo website
    7.  All titles MUST be in Title Case (e.g., "What Is a Java Variable?").
    8.  Your entire response MUST be **ONLY** a single, raw, valid JSON object.

    **EXAMPLE (Your output MUST follow this structure):**
    {
      "category": "Programming",
      "description": "A personalized introduction to Java, focusing on areas you'll find most useful.",
      "image_url": "https://images.pexels.com/photos/270348/pexels-photo-270348.jpeg",
      "learning_objectives": ["Review of Java Basics", "Deep Dive into Loops", "Mastering Conditional Statements"]
    }

    **TOPIC TO PLAN:**
    %s
    """;

    private static final String AI_PERSONALIZED_CURRICULUM_PROMPT = """
    **ROLE & GOAL:**
    You are an expert curriculum planner creating a personalized learning path for a user based on their performance on a placement test.

    **USER CONTEXT:**
    * **Topic:** %s
    * **Assessment Results:** The user struggled with questions related to the following concepts, indicating these are their weak areas: %s

    **INSTRUCTIONS:**
    1.  Analyze the user's weak areas from the assessment results.
    2.  Generate a curriculum of 12-15 logically sequenced learning objective titles in Title Case. You MUST generate a list of exactly 12 to 15 logically sequenced learning objective titles. Do not generate more or less.
    3.  The curriculum MUST start with a brief review of fundamentals but then **focus heavily on the user's identified weak areas**.
    4.  You must stay on topic and avoid introducing unrelated concepts.
    5.  The category field should be a single, broad category (e.g., "Programming", "History", "Science").
    6.  Write a concise, engaging description for the overall topic (2-3 sentences).
    7.  Provide a direct, functional image URL from a free stock photo website
    8.  All titles MUST be in Title Case (e.g., "What Is a Java Variable?").
    9.  Your entire response MUST be **ONLY** a single, raw, valid JSON object.

    **EXAMPLE (Your output MUST follow this structure):**
    {
      "category": "Programming",
      "description": "A personalized introduction to Java, focusing on areas you'll find most useful.",
      "image_url": "https://images.pexels.com/photos/270348/pexels-photo-270348.jpeg",
      "learning_objectives": ["Review of Java Basics", "Deep Dive into Loops", "Mastering Conditional Statements"]
    }

    **TOPIC TO PLAN:**
    %s
    """;

    @Autowired
    private RestTemplate restTemplate;
    @Autowired
    private TopicRepository topicRepository;
    @Autowired
    private ContentProcessingService contentProcessingService;

    @Value("${ai.api.key}")
    private String apiKey;
    @Value("${ai.api.url}")
    private String apiUrl;

    @Async
    public void generateAndSaveGenericCurriculum(String topicName) {
        System.out.println("Generating generic curriculum for topic: " + topicName);
        String promptText = String.format(AI_GENERIC_CURRICULUM_PROMPT, topicName);
        CurriculumDto curriculum = getCurriculumFromAI(promptText);
        processAndSaveFullCurriculum(curriculum, topicName);
    }

    @Async
    public void generatePersonalizedCurriculum(String topic, List<Map<String, String>> userAnswers) {
        String weakAreasSummary = userAnswers.stream()
            .filter(answer -> !answer.get("selectedAnswerKey").equals(answer.get("correctAnswerKey")))
            .map(answer -> answer.get("questionText"))
            .collect(Collectors.joining(", "));

        if (weakAreasSummary.isEmpty()) {
            weakAreasSummary = "general fundamentals, as no specific errors were made.";
        }

        String promptText = String.format(AI_PERSONALIZED_CURRICULUM_PROMPT, topic, weakAreasSummary, topic);
        CurriculumDto curriculum = getCurriculumFromAI(promptText);
        processAndSaveFullCurriculum(curriculum, topic);
    }

    private void processAndSaveFullCurriculum(CurriculumDto curriculum, String topicName) {
        if (curriculum != null && curriculum.getLearningObjectives() != null) {
            Topic mainTopic = topicRepository.findByName(topicName).orElseGet(() -> {
                Topic newTopic = new Topic();
                newTopic.setName(topicName);
                return topicRepository.save(newTopic);
            });
            mainTopic.setCategory(curriculum.getCategory());
            mainTopic.setDescription(curriculum.getDescription());
            mainTopic.setImageUrl(curriculum.getImageUrl());
            mainTopic.setStatus(TopicStatus.GENERATING); // Set status before starting
            topicRepository.save(mainTopic);

            for (int i = 0; i < curriculum.getLearningObjectives().size(); i++) {
                String objectiveTitle = curriculum.getLearningObjectives().get(i);
                System.out.println("\n--- Processing Objective: " + objectiveTitle + " ---");
                contentProcessingService.generateAndSaveContent(topicName, objectiveTitle, i, curriculum.getLearningObjectives().size());
                try {
                    TimeUnit.SECONDS.sleep(10);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
            }
            System.out.println("\n--- FULL CONTENT GENERATION FINISHED for " + topicName + " ---");
        } else {
            System.out.println("Failed to generate curriculum from AI for topic: " + topicName);
        }
    }

    private CurriculumDto getCurriculumFromAI(String promptText) {
        try {
            String jsonResponse = callAi(promptText);
            ObjectMapper objectMapper = new ObjectMapper();
            return objectMapper.readValue(jsonResponse, CurriculumDto.class);
        } catch (IOException e) {
            System.err.println("Error parsing curriculum DTO from AI.");
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