package com.learning;

import com.learning.dto.CurriculumDto;
import com.learning.model.Topic;
import com.learning.repository.TopicRepository;
import com.learning.service.ContentProcessingService;
import com.learning.service.CurriculumService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import java.util.concurrent.TimeUnit;

@SpringBootApplication
public class App implements CommandLineRunner {

    @Autowired
    private CurriculumService curriculumService;
    @Autowired
    private ContentProcessingService contentProcessingService;
    @Autowired
    private TopicRepository topicRepository;

    public static void main(String[] args) {
        SpringApplication.run(App.class, args);
    }

    @Override
    public void run(String... args) throws Exception {
        // System.out.println("--- STARTING FULL CONTENT GENERATION PIPELINE ---");

        // String mainTopicName = "Introduction to Java";

        // CurriculumDto curriculum = curriculumService.generateCurriculum(mainTopicName);

        // if (curriculum != null && curriculum.getLearningObjectives() != null) {
        //     Topic mainTopic = topicRepository.findByName(mainTopicName).orElseGet(() -> {
        //         Topic newTopic = new Topic();
        //         newTopic.setName(mainTopicName);
        //         return topicRepository.save(newTopic);
        //     });
        //     mainTopic.setCategory(curriculum.getCategory());
        //     mainTopic.setDescription(curriculum.getDescription());
        //     mainTopic.setImageUrl(curriculum.getImageUrl());
        //     topicRepository.save(mainTopic);

        //     System.out.println("Generated " + curriculum.getLearningObjectives().size() + " learning objectives for: " + mainTopicName);
        //     System.out.println(curriculum.getLearningObjectives());

        //     System.out.println("--- Rate Limiter: Waiting for 10 seconds... ---");
        //     TimeUnit.SECONDS.sleep(10);

        //     for (int i = 0; i < curriculum.getLearningObjectives().size(); i++) {
        //         String objectiveTitle = curriculum.getLearningObjectives().get(i);
        //         System.out.println("\n--- Processing Objective: " + objectiveTitle + " ---");
                
        //         contentProcessingService.generateAndSaveContent(mainTopicName, objectiveTitle, i);

        //         System.out.println("--- Rate Limiter: Waiting for 10 seconds... ---");
        //         TimeUnit.SECONDS.sleep(10);
        //     }
        // } else {
        //     System.out.println("Failed to generate curriculum. Aborting.");
        // }

        // System.out.println("\n--- FULL CONTENT GENERATION PIPELINE FINISHED ---");
    }
}