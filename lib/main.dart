import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  runApp(const InteriorDesignApp());
}

class InteriorDesignApp extends StatelessWidget {
  const InteriorDesignApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maison Elite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Georgia',
        scaffoldBackgroundColor: const Color(0xFFF8F5F0),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B6914),
          background: const Color(0xFFF8F5F0),
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
