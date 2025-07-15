package com.learning.controller;

import com.learning.dto.LearningObjectiveDetailDto;
import com.learning.service.LearningObjectiveService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/api/learning-objectives")
public class LearningObjectiveController {

    @Autowired
    private LearningObjectiveService learningObjectiveService;

    @GetMapping("/{objectiveId}")
    public LearningObjectiveDetailDto getLearningObjectiveById(@PathVariable UUID objectiveId) {
        return learningObjectiveService.getLearningObjectiveDetails(objectiveId);
    }
}