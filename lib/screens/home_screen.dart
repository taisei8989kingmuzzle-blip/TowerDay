import 'package:flutter_svg/svg.dart';


import 'package:flutter/material.dart';

import '../models/tower_day.dart';
import '../services/screen_time_service.dart';
import '../services/storage_service.dart';
import '../widgets/journal_dialog.dart';
import '../widgets/tower.dart';

import '../models/journal_draft.dart';

import '../widgets/preview_floor.dart';

import '../widgets/today_journal_dialog.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScreenTimeService _screenTimeService =
      ScreenTimeService();

  List<TowerDay> towerDays = [];

  JournalDraft? todayDraft;

  int goalMinutes = 180;
  int todayScreenTime = 120;

  bool checking = false;

  String _dateKey(DateTime date) {
    final localDate = DateTime(date.year, date.month, date.day);

    return '${localDate.year}-'
        '${localDate.month.toString().padLeft(2, '0')}-'
        '${localDate.day.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

    Future<void> _loadData() async {
    try {
      final goal = await StorageService.getGoal();
      final days = await StorageService.getTowerDays();
      final screenTime =
          await _screenTimeService.getTodayScreenTimeMinutes();
      final draft = await StorageService.getJournalDraft(
        _dateKey(DateTime.now()),
      );

      if (!mounted) return;

      setState(() {
        goalMinutes = goal ?? 180;
        towerDays = days;
        todayScreenTime = screenTime;
        todayDraft = draft;
      });

      // Process completed dates only after saved data is loaded.
      await _processCompletedDays();
    } catch (e) {
      debugPrint('Failed to load tower data: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not load tower data: $e'),
        ),
      );
    }
  }
  Future<void> _showTodayJournal() async {
    final todayKey = _dateKey(DateTime.now());

    final existingDraft = 
      await StorageService.getJournalDraft(todayKey);

    if(!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (_) => TodayJournalDialog(
        initialDraft: existingDraft,
        goalMinutes: goalMinutes,
        onSaved: () async {
          await _loadData();
        },
      ),
    );
  }
  Future<void> _processToday(int screenTime) async {
    if(!mounted) return;

    final todayKey = _dateKey(DateTime.now());

    final alreadyChecked = towerDays.any(
      (day) => _dateKey(DateTime.parse(day.date)) == todayKey,
    );

    if(alreadyChecked) {
      return;
    }

    if(screenTime <= goalMinutes) {
      await _successfulDay(screenTime);
    } else {
      await _failedDay(screenTime);
    }
  }

    Future<void> _processCompletedDays() async {
    if (checking) return;

    setState(() => checking = true);

    try {
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final yesterday = todayStart.subtract(const Duration(days: 1));

      final lastProcessed =
          await StorageService.getLastProcessedDate();

      // On first run, evaluate yesterday only.
      DateTime nextDate = lastProcessed == null
          ? yesterday
          : DateTime.parse(lastProcessed)
              .add(const Duration(days: 1));

      while (nextDate.isBefore(todayStart)) {
        final dateKey = _dateKey(nextDate);

        final alreadyProcessed =
            await StorageService.isDateProcessed(dateKey);

        if (!alreadyProcessed) {
          final minutes =
              await _screenTimeService.getScreenTimeForDate(nextDate);

          final draft =
              await StorageService.getJournalDraft(dateKey);

          final dayGoal = draft?.goalMinutes ?? goalMinutes;

          if (minutes <= dayGoal) {
            final completedDay = TowerDay(
              date: nextDate.toIso8601String(),
              feeling: draft?.feeling ?? '😐 Okay',
              note: draft?.note ?? '',
              screenTimeMinutes: minutes,
              goalMinutes: dayGoal,
            );

            towerDays = [...towerDays, completedDay];

            await StorageService.saveTowerDays(towerDays);
            await StorageService.deleteJournalDraft(dateKey);
          } else {
            // Preserve the existing tower before collapsing it.
            await StorageService.saveFallenTower(towerDays);
            await StorageService.clearTower();

            towerDays = [];

            // Discard the failed day's journal draft.
            await StorageService.deleteJournalDraft(dateKey);
          }

          await StorageService.markDateProcessed(dateKey);
        }

        await StorageService.setLastProcessedDate(dateKey);

        nextDate = nextDate.add(const Duration(days: 1));
      }

      final refreshedDays = await StorageService.getTowerDays();
      final refreshedDraft = await StorageService.getJournalDraft(
        _dateKey(DateTime.now()),
      );
      final currentMinutes =
          await _screenTimeService.getTodayScreenTimeMinutes();

      if (!mounted) return;

      setState(() {
        towerDays = refreshedDays;
        todayDraft = refreshedDraft;
        todayScreenTime = currentMinutes;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not process screen time: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => checking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final remaining =
        goalMinutes - todayScreenTime;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Tower',
        ),
        backgroundColor: Colors.transparent,
      ),

      body: 
      
      Stack(
        fit: StackFit.expand,
        children: [
          SvgPicture.asset(
            'assets/TowerDayBackground.svg',
            fit: BoxFit.cover,
          ),

          SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 5),
        
              Text(
                '${towerDays.length} day tower',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6F4935),
                ),
              ),
        
              const SizedBox(height: 15),
        
              Expanded(
              child: Column(
                children: [
                  PreviewFloor(
                    floorNumber: towerDays.length + 1,
                    onTap: _showTodayJournal,
                  ),
                  Expanded(
                    child: Center(
                      child: towerDays.isEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/SetupScreenLogo.svg',
                                  width: 190,
                                  height: 190,
                                ),
                                const SizedBox(height: 15),
                                const Text(
                                  'Your tower is waiting\nfor its first floor.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF6F4935),
                                  ),
                                ),
                              ],
                            )
                          : Tower(
                              days: towerDays,
                              onFloorTap: _showJournal,
                            ),
                    ),
                  ),
                ],
              ),
            ),
        
              Container(
                margin: const EdgeInsets.all(18),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8D2),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Yesterday's Screen Time",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
        
                    const SizedBox(height: 8),
        
                    Text(
                      '${_formatMinutes(todayScreenTime)} / '
                      '${_formatMinutes(goalMinutes)}',
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6F4935),
                      ),
                    ),
        
                    const SizedBox(height: 5),
        
                    Text(
                      remaining >= 0
                          ? '${_formatMinutes(remaining)} remaining'
                          : '${_formatMinutes(-remaining)} over goal',
                      style: TextStyle(
                        fontSize: 14,
                        color: remaining >= 0
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
        
                    const SizedBox(height: 15),
        
                    // FilledButton(
                    //   onPressed:
                    //       checking ? null : _checkToday,
                    //   child: Padding(
                    //     padding: const EdgeInsets.symmetric(
                    //       horizontal: 18,
                    //       vertical: 12,
                    //     ),
                    //     child: Text(
                    //       checking
                    //           ? 'Checking...'
                    //           : "Check Today's Progress",
                    //     ),
                    //   ),
                    // ),
        
                    const SizedBox(height: 8),
        
                    TextButton(
                      onPressed: _showDemoControls,
                      child: const Text(
                        'Demo: Change Screen Time',
                      ),
                    ),
        
                    TextButton(
                      onPressed: _resetForTesting,
                      child: const Text(
                        'reset screen time check for the day',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ],
      ),
    );
  }

  Future<void> _checkToday() async {
    if (checking) return;

    setState(() {
      checking = true;
    });

    try {
    final screenTime =
        await _screenTimeService.getTodayScreenTimeMinutes().timeout(const Duration(seconds: 10));

    if (!mounted) return;

    setState(() {
      todayScreenTime = screenTime;
    });

    // Prevent adding another floor on the same day.
    final todayKey = _dateKey(DateTime.now());

    final alreadyChecked = towerDays.any(
      (day) => _dateKey(DateTime.parse(day.date)) == todayKey,
    );

    if (alreadyChecked) {
      setState(() {
        checking = false;
      });

      _showMessage(
        'Today has already been checked.',
        false,
      );

      return;
    }

    if (screenTime <= goalMinutes) {
      await _successfulDay(screenTime);
    } else {
      await _failedDay(screenTime);
    }
    } catch (e) {
      debugPrint('Screen-time check failed: $e');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Could not read screen time: $e'),
      ),
    );
    } finally {
      if(mounted) {
        setState(() {
          checking = false;
        });
      }

    
    }
  }

  

  Future<void> _restoreFallenTower(
    List <TowerDay> fallenTower,
  ) async {
    await StorageService.saveTowerDays(
      fallenTower,
    );

    await StorageService.clearFallenTower();

    if(!mounted) return;

    setState(() {
      towerDays = List<TowerDay>.from(fallenTower);
    });

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${fallenTower.length} floors'
            'have been reconstructed',
          ),
        )   ,     
    );
  }

  Future<void> _successfulDay(int screenTime) async {
    final day = TowerDay(
      date: DateTime.now().toIso8601String(),
      feeling: '😊 Happy',
      note: 'I stayed under my screen-time goal!',
      screenTimeMinutes: screenTime,
      goalMinutes: goalMinutes,
    );

    setState(() {
      towerDays.add(day);
    });

    await StorageService.saveTowerDays(towerDays);

    if (!mounted) return;

    _showSuccess();
  }

  Future<void> _failedDay(int screenTime) async {
  // Save the tower BEFORE clearing it.
  await StorageService.saveFallenTower(towerDays);

  // Now collapse the current tower.
  await StorageService.clearTower();

  setState(() {
    towerDays.clear();
  });

  if (!mounted) return;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          '💥 The tower collapsed',
        ),
        content: Text(
          'You used ${_formatMinutes(screenTime)}, '
          'which is over your '
          '${_formatMinutes(goalMinutes)} goal.\n\n'
          'You can rebuild your tower using the '
          'Reconstruction Kit.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Start Again'),
          ),
        ],
      );
    },
  );
}

  void _showSuccess() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            '🎉 Floor added!',
          ),
          content: const Text(
            'You stayed under your screen-time goal.\n\n'
            'Your tower grew by one floor!',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Keep Building'),
            ),
          ],
        );
      },
    );
  }

  void _showJournal(int index) {
    if (index < 0 || index >= towerDays.length) {
      return;
    }

    final day = towerDays[index];

    showDialog(
  context: context,
  builder: (_) => JournalDialog(
    day: day,
    floorNumber: index + 1,
    onSaved: _loadData,
  ),
);
  }

  Future<void> _resetForTesting() async {
    await StorageService.resetTowerForTesting();

    if (!mounted) return;

    setState(() {
      towerDays = [];
      todayDraft = null;
    });

    await _loadData();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tower test data has been reset.'),
      ),
    );
  }

  void _showDemoControls() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Demo Screen Time',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Choose a value to simulate today.',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                _demoButton(
                  '😊 Under goal — 1h 30m',
                  90,
                ),

                _demoButton(
                  '🙂 Under goal — 2h',
                  120,
                ),

                _demoButton(
                  '😐 Near goal — 2h 50m',
                  170,
                ),

                _demoButton(
                  '💥 Over goal — 4h',
                  240,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _demoButton(
    String label,
    int minutes,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: OutlinedButton(
          onPressed: () async {
            _screenTimeService.setDemoMinutes(
              minutes,
            );

            setState(() {
              todayScreenTime = minutes;
            });

            Navigator.pop(context);

          },
          child: Text(label),
        ),
      ),
    );
  }

  void _showMessage(
    String message,
    bool success,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  

  String _formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours == 0) {
      return '${mins}m';
    }

    if (mins == 0) {
      return '${hours}h';
    }

    return '${hours}h ${mins}m';
  }
}