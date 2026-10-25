import 'package:flutter/material.dart';

import '../models/journal_draft.dart';
import '../services/storage_service.dart';

class TodayJournalDialog extends StatefulWidget {
  final JournalDraft? initialDraft;
  final int goalMinutes;
  final Future<void> Function() onSaved;

  const TodayJournalDialog({
    super.key,
    required this.initialDraft,
    required this.goalMinutes,
    required this.onSaved,
  });

  @override
  State<TodayJournalDialog> createState() =>
      _TodayJournalDialogState();
}

class _TodayJournalDialogState
    extends State<TodayJournalDialog> {
  final TextEditingController _noteController =
      TextEditingController();

  String _feeling = '😐 Okay';
  bool _saving = false;

  @override
  void initState() {
    super.initState();

    final draft = widget.initialDraft;

    if (draft != null) {
      _feeling = draft.feeling;
      _noteController.text = draft.note;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveDraft() async {
    if (_saving) return;

    setState(() => _saving = true);

    try {
      final now = DateTime.now();
      final dateKey =
          '${now.year}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}';

      final draft = JournalDraft(
        date: dateKey,
        feeling: _feeling,
        note: _noteController.text.trim(),
        goalMinutes: widget.goalMinutes,
      );

      await StorageService.saveJournalDraft(draft);
      await widget.onSaved();

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save journal: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Today's Journal"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('How are you feeling today?'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _feeling,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: '😊 Happy',
                  child: Text('😊 Happy'),
                ),
                DropdownMenuItem(
                  value: '😌 Calm',
                  child: Text('😌 Calm'),
                ),
                DropdownMenuItem(
                  value: '😐 Okay',
                  child: Text('😐 Okay'),
                ),
                DropdownMenuItem(
                  value: '😓 Stressed',
                  child: Text('😓 Stressed'),
                ),
                DropdownMenuItem(
                  value: '😴 Tired',
                  child: Text('😴 Tired'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _feeling = value);
                }
              },
            ),
            const SizedBox(height: 16),
            const Text('Anything you want to remember?'),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Write a little about your day...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your journal becomes permanent only if '
              'you meet your screen-time goal.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _saveDraft,
          child: Text(_saving ? 'Saving...' : 'Save draft'),
        ),
      ],
    );
  }
}