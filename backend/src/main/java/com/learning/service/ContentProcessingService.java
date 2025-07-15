package com.learning.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.learning.dto.ContentBlockDto;
import com.learning.dto.GeminiTextRequest;
import com.learning.dto.GeminiTextResponse;
import com.learning.dto.QuestionDTO;
import com.learning.dto.StructuredContentDto;
import com.learning.model.*;
import com.learning.repository.ContentBlockRepository;
import com.learning.repository.LearningObjectRepository;
import com.learning.repository.QuestionRepository;
import com.learning.repository.TopicRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import java.io.IOException;
import java.util.ArrayList;

@Service
public class ContentProcessingService {

    // --- Prompt broken into parts for readability ---

    private static final String ROLE_AND_GOAL = """
    **ROLE & GOAL:**
    You are an expert curriculum developer with a friendly, encouraging, and slightly playful tone. Your task is to create a complete, structured digital lesson based on the provided learning objective.
    """;

    private static final String CRITICAL_INSTRUCTIONS = """
    **CRITICAL INSTRUCTIONS:**
    1.  **Tone:** Your generated text content MUST be clear, engaging, and encouraging. Avoid dry, academic language.
    2.  **Strict JSON-Only Output:** Your ENTIRE response MUST be a single, raw, valid JSON object. Do NOT wrap it in Markdown.
    3.  **Escape Special Characters:** All string values within the JSON MUST be properly escaped.
    4.  **Final Check:** Before you finish, you MUST validate your own output to ensure it is a single, raw, syntactically perfect JSON object.
    """;

    private static final String FIELD_CONSTRAINTS = """
    **FIELD CONSTRAINTS (NON-NEGOTIABLE):**
    * `title`: String. A concise, engaging title for this specific lesson.
    * `difficulty`: Integer. A number from 1 (beginner) to 10 (expert).
    * `tags`: String Array. Exactly 3 to 5 relevant lowercase keywords.
    * `content_blocks`: Array of Objects. MUST contain 3 to 5 content blocks. One block should be a `SUMMARY`, and at least one MUST be a `CODE_QUIZ`.
    * `content_blocks.block_type`: MUST be one of: `SUMMARY`, `DETAILED_EXPLANATION`, `CODE_EXAMPLE`, `CODE_QUIZ`.
    * `content_blocks.content`:
        * For `CODE_EXAMPLE`, format is: `Description text.|||pure_code_here`.
        * For `CODE_QUIZ`, format is: `A code snippet with a [BLANK] or a bug to be fixed.`.
    * `content_blocks.questions`: Each block MUST have 1 or 2 questions. For a `CODE_QUIZ`, the question should ask the user to fill the blank or fix the bug, and the options should be code fragments.
    * `final_quiz_questions`: Array of 2 to 4 summative questions.
    """;

    private static final String PERFECT_EXAMPLE = """
    **PERFECT EXAMPLE (Your output structure must identically match this):**
    {
      "title": "Introduction to Python Lists",
      "difficulty": 2,
      "tags": ["python", "lists", "data-structures", "collections"],
      "content_blocks": [
        {
          "block_type": "SUMMARY",
          "content": "A Python list is an ordered and mutable collection of items. Lists are one of Python's most versatile built-in data types.",
          "questions": [
            {
              "question_text": "What are the two main characteristics of a Python list?",
              "options": {"a": "Ordered and immutable", "b": "Ordered and mutable"},
              "correct_answer": "b",
              "explanation": "Lists maintain the order of elements and can be changed, making them mutable."
            }
          ]
        },
        {
          "block_type": "CODE_QUIZ",
          "content": "To add an item to the end of a list named 'my_list', you would use the `[BLANK]` method.",
          "questions": [
            {
              "question_text": "Fill in the blank to correctly add an item.",
              "options": {"a": ".add()", "b": ".append()", "c": ".push()"},
              "correct_answer": "b",
              "explanation": "`.append()` is the correct method for adding an item to the end of a Python list."
            }
          ]
        }
      ],
      "final_quiz_questions": [
        {
          "question_text": "How would you access the second element in the list `fruits = ['apple', 'banana', 'cherry']`?",
          "options": {"a": "fruits(1)", "b": "fruits[1]"},
          "correct_answer": "b",
          "explanation": "Python uses zero-based indexing, so the second element is at index 1."
        }
      ]
    }
    """;

    private static final String YOUR_TASK = """
    **YOUR TASK:**
    Generate a complete lesson for the following learning objective. Remember: your response must be **ONLY** the raw JSON object, validated for correctness.

    **LEARNING OBJECTIVE:**
    %s
    """;

    private static final String AI_PROMPT_TEMPLATE = String.join("\n\n", ROLE_AND_GOAL, CRITICAL_INSTRUCTIONS, FIELD_CONSTRAINTS, PERFECT_EXAMPLE, YOUR_TASK);
    
    @Autowired
    private TopicRepository topicRepository;
    @Autowired
    private LearningObjectRepository learningObjectRepository;
    @Autowired
    private QuestionRepository questionRepository;
    @Autowired
    private ContentBlockRepository contentBlockRepository;
    @Autowired
    private RestTemplate restTemplate;

    @Value("${ai.api.key}")
    private String apiKey;
    @Value("${ai.api.url}")
    private String apiUrl;

    @Transactional
    public void generateAndSaveContent(String mainTopicName, String learningObjectiveTitle, int order) {
        System.out.println("Starting content generation for objective: " + learningObjectiveTitle);
        try {
            String promptText = String.format(AI_PROMPT_TEMPLATE, learningObjectiveTitle);
            GeminiTextRequest apiRequest = new GeminiTextRequest(promptText);
            String urlWithKey = apiUrl + "?key=" + apiKey;

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            HttpEntity<GeminiTextRequest> entity = new HttpEntity<>(apiRequest, headers);
            GeminiTextResponse geminiResponse = restTemplate.postForObject(urlWithKey, entity, GeminiTextResponse.class);

            if (geminiResponse != null && !geminiResponse.getCandidates().isEmpty()) {
                String rawAiResponse = geminiResponse.getCandidates().get(0).getContent().getParts().get(0).getText();
                String cleanedJson = rawAiResponse.trim().replace("```json", "").replace("```", "").trim();
                
                ObjectMapper objectMapper = new ObjectMapper();
                StructuredContentDto structuredData = objectMapper.readValue(cleanedJson, StructuredContentDto.class);
                System.out.println("Successfully parsed AI response for title: " + structuredData.getTitle());

                Topic topic = topicRepository.findByName(mainTopicName).orElseThrow(() -> new RuntimeException("Parent topic not found!"));
                
                LearningObject learningObject = new LearningObject();
                learningObject.setTopic(topic);
                learningObject.setTitle(structuredData.getTitle());
                learningObject.setDifficulty(structuredData.getDifficulty());
                learningObject.setTags(structuredData.getTags());
                learningObject.setLearningOrder(order);
                learningObject.setContentBlocks(new ArrayList<>());
                
                LearningObject savedLearningObject = learningObjectRepository.save(learningObject);

                int blockOrder = 1;
                for (ContentBlockDto blockDto : structuredData.getContent_blocks()) {
                    ContentBlock block = new ContentBlock();
                    block.setLearningObject(savedLearningObject);
                    block.setBlockOrder(blockOrder++);
                    block.setBlockType(blockDto.getBlock_type());
                    block.setContentPayload(blockDto.getContent());
                    ContentBlock savedBlock = contentBlockRepository.save(block);

                    if (blockDto.getQuestions() != null) {
                        for (QuestionDTO questionDto : blockDto.getQuestions()) {
                            saveQuestion(questionDto, null, savedBlock, objectMapper);
                        }
                    }
                }

                if (structuredData.getFinal_quiz_questions() != null) {
                    for (QuestionDTO questionDto : structuredData.getFinal_quiz_questions()) {
                        saveQuestion(questionDto, savedLearningObject, null, objectMapper);
                    }
                }
                System.out.println("Successfully saved complete Learning Object structure for: " + savedLearningObject.getTitle());
            }
        } catch (IOException e) {
            System.err.println("Error processing objective: " + learningObjectiveTitle);
            e.printStackTrace();
        }
    }

    private void saveQuestion(QuestionDTO dto, LearningObject lo, ContentBlock cb, ObjectMapper mapper) {
        Question q = new Question();
        q.setLearningObject(lo);
        q.setContentBlock(cb);
        q.setQuestionText(dto.getQuestion_text());
        try {
            q.setOptions(mapper.writeValueAsString(dto.getOptions()));
        } catch (JsonProcessingException e) {
            e.printStackTrace();
        }
        q.setCorrectAnswer(dto.getCorrect_answer());
        q.setExplanation(dto.getExplanation());
        questionRepository.save(q);
    }
}