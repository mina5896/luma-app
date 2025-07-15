package com.learning.controller;

import com.learning.dto.TopicDetailDto;
import com.learning.dto.TopicSummaryDto; // Import the new DTO
import com.learning.service.TopicService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/topics")
public class TopicController {

    @Autowired
    private TopicService topicService;

    // --- THIS METHOD IS UPDATED ---
    @GetMapping
    public List<TopicSummaryDto> getAllTopicSummaries() {
        return topicService.getTopicSummaries();
    }

    @GetMapping("/{topicId}")
    public TopicDetailDto getTopicById(@PathVariable UUID topicId) {
        return topicService.getTopicDetails(topicId);
    }
}