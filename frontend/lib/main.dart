import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luma/screens/topics_screen.dart';

void main() {
  runApp(const LumaApp());
}

class LumaApp extends StatelessWidget {
  const LumaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Luma',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
          primary: Colors.blue.shade300,
          background: const Color(0xFF1F1F1F),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        textTheme: GoogleFonts.nunitoTextTheme(
          Theme.of(context).textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1F1F1F),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: GoogleFonts.nunito(
            color: Colors.white,
            // --- THIS IS THE FIX ---
            fontSize: 20, // Reduced from 22
            fontWeight: FontWeight.bold,
          ),
        ),
        useMaterial3: true,
      ),
      home: const TopicsScreen(),
    );
  }
}