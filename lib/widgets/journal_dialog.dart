import 'package:flutter/material.dart';
import '../models/tower_day.dart';

class JournalDialog extends StatelessWidget {
  final TowerDay day;

  const JournalDialog({
    super.key,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(day.date);

    return AlertDialog(
      title: Text(
        '${date.month}/${date.day}/${date.year}',
      ),

      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            day.feeling,
            style: const TextStyle(
              fontSize: 22,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            day.note,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            'Screen Time: ${day.screenTimeMinutes} minutes',
          ),

          Text(
            'Goal: ${day.goalMinutes} minutes',
          ),
        ],
      ),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}