import 'package:flutter/material.dart';
import 'screens/setup_screen.dart';

void main() {
  runApp(const TowerApp());
}

class TowerApp extends StatelessWidget {
  const TowerApp ({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Little Tower',

      theme: ThemeData(
        useMaterial3: true,

        scaffoldBackgroundColor: 
          const Color(0xFFFFF7ED),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color (0xFFE8A06A),
        ),

        fontFamily: 'sans',
      ),

      home: const SetupScreen(),
    );
  }
}