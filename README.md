💡 Luma: The AI-Powered Learning App
Luma is an adaptive, gamified learning application designed to create personalized educational journeys for any topic. Inspired by the engaging user experience of Duolingo, Luma uses Google's Gemini AI to generate entire courses, from high-level curriculum planning down to individual lessons and quizzes, all tailored to the user's knowledge level.

This repository contains the full source code for both the Java/Spring Boot backend and the Flutter mobile frontend.

✨ Core Features
Adaptive Curriculum Generation: Users can enter any topic (e.g., "Python for Data Science"), and the AI backend generates a complete, multi-lesson course from scratch.

Personalized Placement Tests: Before a course is created, the AI generates a placement test to assess the user's existing knowledge. The final curriculum is tailored to focus on the user's weak areas.

Gamified Learning Path: Course content is presented as a visually engaging, island-hopping path. Users unlock new lessons sequentially, with animations to celebrate their progress.

Interactive Lessons: Lessons are broken down into bite-sized content blocks, including summaries, detailed explanations, and code examples with syntax highlighting.

Engaging Quizzes: Quizzes provide instant, colorful feedback, complete with an animated Luma mascot to encourage the user.

User Profiles & Persistence: The app saves all user progress locally, including unlocked lessons, total XP, daily learning streaks, and achievement badges for completed topics.

🛠️ Technology Stack
Backend
Language: Java 17

Framework: Spring Boot 3

Build Tool: Maven

Database: PostgreSQL

AI: Google Gemini API

Libraries: Spring Data JPA, Jsoup (for initial web scraping experiments)

Frontend
Framework: Flutter

Language: Dart

State Management: StatefulWidget (setState)

Networking: http package

Local Storage: shared_preferences

UI & Theming: google_fonts

🚀 Setup and Installation
To run the Luma app, you need to set up both the backend server and the frontend mobile application.

Backend Setup
Prerequisites:

Java Development Kit (JDK) 17 or higher.

Apache Maven.

A running PostgreSQL database instance.

Configuration:

Open the src/main/resources/application.properties file.

Update spring.datasource.url, spring.datasource.username, and spring.datasource.password with your local PostgreSQL credentials.

Update ai.api.key with your Google Gemini API key.

Set spring.jpa.hibernate.ddl-auto to create to generate a fresh database on the first run. Change it to update for subsequent runs to preserve your data.

Run the Server:

Open the Java project in your IDE (like VS Code or IntelliJ).

Run the main App.java class. The server will start on localhost:8080.

Frontend Setup
Prerequisites:

Flutter SDK.

Android Studio (with Android SDK) and/or Xcode for building to a mobile device.

Install Dependencies:

Open a terminal in the root of the /luma Flutter project folder.

Run the command: flutter pub get

Configure API Connection:

Find your computer's local IP address (e.g., 192.168.1.XX).

Open the lib/services/api_service.dart file.

Update the _baseUrl variable with your computer's IP address and port 8080.

final String _baseUrl = "http://YOUR_COMPUTER_IP:8080/api";

Run the App:

Connect your physical Android or iOS device via USB, or start an emulator.

Ensure your device/emulator and your laptop are on the same Wi-Fi network.

In VS Code, select your device from the bottom-right corner and press F5 to build and run the app.
