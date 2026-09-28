import 'package:flutter/material.dart';

import '../models/tower_day.dart';
import '../services/storage_service.dart';
import '../widgets/tower.dart';
import '../widgets/journal_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen ({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TowerDay> towerDays = [];

  int goalMinutes = 180;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final goal = await StorageService.getGoal();
    final days = await StorageService.getTowerDays();

    setState(() {
      goalMinutes = goal ?? 180;
      towerDays = days;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Tower',
        ),
        backgroundColor: Colors.transparent,
      ),

      body: SafeArea(
        child: Column(
          children:[
            const SizedBox(height: 15),

            Text(
              '${towerDays.length} day tower',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6F4935),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Center(
                child: towerDays.isEmpty
                    ? const Text(
                      'Your tower is waiting for its \nfirst floor.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    )
                  : Tower(
                    floorCount: towerDays.length,
                    onFloorTap: () {
                      _showLatestJournal();
                    },
                  ) ,
              ),
            ),

            Container(
              margin: const EdgeInsets.all(20),

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: const Color(0xFFFFE8D2),
                borderRadius: BorderRadius.circular(20),
              ),

              child: Column(
                children: [
                  const Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text (
                    'Goal: ${_formatMinutes(goalMinutes)}',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 15),

                  FilledButton(
                    onPressed: _addTestFloor,
                    child: const Text(
                      'Test: Complete Day',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (mins == 0) {
      return '${hours}h';
    }

    return '${hours}h ${mins}m';
  }

  Future<void> _addTestFloor() async {
    final today = DateTime.now();

    final day = TowerDay(
      date: today.toIso8601String(),
      feeling: 'happy',
      note:'A successful day!',
      screenTimeMinutes: goalMinutes - 20,
      goalMinutes: goalMinutes,
    );

    setState(() {
      towerDays.add(day);
    });

    await StorageService.saveTowerDays(
      towerDays,
    );
  }

  void _showLatestJournal() {
    if (towerDays.isEmpty) return;

    final day = towerDays.last;

    showDialog(
      context: context,
      builder: (_) => JournalDialog(
        day: day,
      ),
    );
  }
}