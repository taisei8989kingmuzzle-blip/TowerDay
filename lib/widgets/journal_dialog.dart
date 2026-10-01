import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../models/tower_day.dart';
import '../services/storage_service.dart';

class JournalDialog extends StatefulWidget {
  final TowerDay day;
  final int floorNumber;
  final VoidCallback? onSaved;

  const JournalDialog({
    super.key,
    required this.day,
    required this.floorNumber,
    this.onSaved,
  });

  @override
  State<JournalDialog> createState() =>
      _JournalDialogState();
}

class _JournalDialogState
    extends State<JournalDialog> {

  late String selectedFeeling;
  late TextEditingController noteController;

  final feelings = [
    '😊 Happy',
    '😌 Calm',
    '😄 Excited',
    '😐 Okay',
    '😴 Tired',
    '😤 Frustrated',
  ];

  @override
  void initState() {
    super.initState();

    selectedFeeling = widget.day.feeling;

    noteController = TextEditingController(
      text: widget.day.note,
    );
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final updatedDay = TowerDay(
      date: widget.day.date,
      feeling: selectedFeeling,
      note: noteController.text.trim(),
      screenTimeMinutes:
          widget.day.screenTimeMinutes,
      goalMinutes: widget.day.goalMinutes,
    );

    final days =
        await StorageService.getTowerDays();

    final index = days.indexWhere(
      (day) => day.date == widget.day.date,
    );

    if (index != -1) {
      days[index] = updatedDay;
      await StorageService.saveTowerDays(days);
    }

    if (!mounted) return;

    Navigator.pop(context);
    widget.onSaved?.call();
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(widget.day.date);

    return AlertDialog(
      title: Row(
        children: [
          SvgPicture.asset(
            'assets/SetupScreenLogo.svg',
            width: 250,
            height: 250,
          ),
          const SizedBox(width: 10),
          Text('Day ${widget.floorNumber}'),
        ],
      ),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              '${date.month}/${date.day}/${date.year}',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'How were you feeling?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: selectedFeeling,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: feelings.map(
                (feeling) {
                  return DropdownMenuItem(
                    value: feeling,
                    child: Text(feeling),
                  );
                },
              ).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedFeeling = value;
                  });
                }
              },
            ),

            const SizedBox(height: 18),

            const Text(
              'Journal',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText:
                    'Write something about today...',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Screen time: '
              '${_formatMinutes(widget.day.screenTimeMinutes)}',
            ),

            Text(
              'Goal: '
              '${_formatMinutes(widget.day.goalMinutes)}',
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),

        FilledButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
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