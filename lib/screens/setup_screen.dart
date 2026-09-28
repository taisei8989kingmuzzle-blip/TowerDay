import 'package:flutter/material.dart';
import '../services/storage_service.dart';

import 'home_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int selectedGoal = 180;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(30),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  const Text(
                    '🏰',
                    style: TextStyle(
                      fontSize: 70,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'My Tower',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6F4935),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Build your tower one day at a time',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      color: Color(0xFF6F4935),
                    ),
                  ),

                  const SizedBox(height: 45),

                  const Text(
                    'Choose your daily screen-time goal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,

                    ),
                  ),

                  const SizedBox(height: 20),

                  DropdownButton<int>(
                    value: selectedGoal,

                    items: const [
                      DropdownMenuItem(
                        value: 60,
                        child:Text('1 hour'),
                      ),
                      DropdownMenuItem(
                        value: 120,
                        child: Text('2 hours'),
                      ),
                      DropdownMenuItem(
                        value: 180,
                        child: Text('3 hours'),
                      ),
                      DropdownMenuItem(
                        value: 240,
                        child: Text('4 hours'),
                      ),
                      DropdownMenuItem(
                        value: 300,
                        child: Text ('5 hours'),
                      ),
                    ],

                    onChanged: (value) {
                      if(value != null) {
                        setState(() {
                          selectedGoal = value;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 35),

                  FilledButton(
                    onPressed: () async {
                      await StorageService.saveGoal(
                        selectedGoal,
                      );

                      if (!context.mounted) return;

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomeScreen(),
                        ),
                      );
                    },

                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 14,
                      ),

                      child: Text(
                        'Begin Building',
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}