package com.learning;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;

@SpringBootApplication
@EnableAsync // Enable asynchronous methods for our curriculum generation
public class App implements CommandLineRunner {

    public static void main(String[] args) {
        SpringApplication.run(App.class, args);
    }

    @Override
    public void run(String... args) throws Exception {
        // We leave this empty now. The application will start and wait for API calls
        // from the Flutter app instead of generating content automatically.
        System.out.println("--- Luma Backend Server is running ---");
    }
}