package com.learning.controller;

import com.learning.dto.QuestionDetailDto;
import com.learning.service.QuestionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/questions")
public class QuestionController {

    @Autowired
    private QuestionService questionService;

    // New endpoint to get details for a list of question IDs
    @PostMapping("/details")
    public List<QuestionDetailDto> getQuestionDetails(@RequestBody List<UUID> questionIds) {
        return questionService.getQuestionDetailsByIds(questionIds);
    }
}