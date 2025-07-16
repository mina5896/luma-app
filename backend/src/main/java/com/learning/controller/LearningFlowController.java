package com.learning.controller;

import com.learning.dto.AssessmentQuestionDto;
import com.learning.dto.AssessmentRequestDto;
import com.learning.dto.PersonalizedCurriculumRequestDto;
import com.learning.service.AssessmentService;
import com.learning.service.CurriculumService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/learning-flow")
public class LearningFlowController {

    @Autowired
    private AssessmentService assessmentService;

    @Autowired
    private CurriculumService curriculumService;

    @PostMapping("/assessment")
    public List<AssessmentQuestionDto> getAssessment(@RequestBody AssessmentRequestDto request) {
        return assessmentService.generateAssessment(request.getTopic());
    }

    @PostMapping("/generate-curriculum")
    public ResponseEntity<Void> generatePersonalizedCurriculum(@RequestBody PersonalizedCurriculumRequestDto request) {
        System.out.println("Received request to generate curriculum for topic: " + request.getTopic());
        System.out.println("User Answers: " + request.getUserAnswers());
        
        // --- THIS IS THE CORRECTED PART ---
        // This now correctly calls the asynchronous service method.
        // The service will run in the background, and the API will return an immediate "202 Accepted" response.
        curriculumService.generatePersonalizedCurriculum(request.getTopic(), request.getUserAnswers());
        
        return ResponseEntity.accepted().build();
    }
}