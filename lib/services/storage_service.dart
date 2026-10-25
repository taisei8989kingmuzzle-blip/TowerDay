import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../models/journal_draft.dart';
import '../models/tower_day.dart';

class StorageService {
  static const String _journalDraftsKey = 'journal_drafts_by_date';
  static const String _processedDatesKey = 'processed_tower_dates';

  static const String _goalKey = 'goal_minutes';
  static const String _towerKey = 'tower_days';

  // Stores the tower that existed immediately before a collapse.
  static const String _fallenTowerKey = 'fallen_tower_days';

  static const String _lastProcessedDateKey = 
    'last_processed_tower_date';

  static Future<String?> getLastProcessedDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastProcessedDateKey);
  }

  static Future<void> setLastProcessedDate(String dateKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastProcessedDateKey, dateKey);
  }

  static Future<void> saveGoal(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_goalKey, minutes);
  }

  static Future<int?> getGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_goalKey);
  }

  static Future<void> saveTowerDays(
    List<TowerDay> days,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final data = days
        .map((day) => jsonEncode(day.toJson()))
        .toList();

    await prefs.setStringList(
      _towerKey,
      data,
    );
  }

  static Future<Map<String, JournalDraft>> getJournalDrafts() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_journalDraftsKey);

  if (raw == null || raw.isEmpty) {
    return {};
  }

  final decoded = jsonDecode(raw) as Map<String, dynamic>;

  return decoded.map(
    (key, value) => MapEntry(
      key,
      JournalDraft.fromJson(
        Map<String, dynamic>.from(value as Map),
      ),
    ),
  );
}

static Future<JournalDraft?> getJournalDraft(String dateKey) async {
  final drafts = await getJournalDrafts();
  return drafts[dateKey];
}

static Future<void> saveJournalDraft(JournalDraft draft) async {
  final prefs = await SharedPreferences.getInstance();
  final drafts = await getJournalDrafts();

  drafts[draft.date] = draft;

  final encoded = jsonEncode(
    drafts.map((key, value) => MapEntry(key, value.toJson())),
  );

  await prefs.setString(_journalDraftsKey, encoded);
}

static Future<void> deleteJournalDraft(String dateKey) async {
  final prefs = await SharedPreferences.getInstance();
  final drafts = await getJournalDrafts();

  drafts.remove(dateKey);

  await prefs.setString(
    _journalDraftsKey,
    jsonEncode(
      drafts.map((key, value) => MapEntry(key, value.toJson())),
    ),
  );
}

  static Future<bool> isDateProcessed(String dateKey) async {
    final prefs = await SharedPreferences.getInstance();
    final dates = prefs.getStringList(_processedDatesKey) ?? [];

    return dates.contains(dateKey);
  }
  
  static Future<void> markDateProcessed(String dateKey) async {
    final prefs = await SharedPreferences.getInstance();
    final dates = prefs.getStringList(_processedDatesKey) ?? [];

    if (!dates.contains(dateKey)) {
      dates.add(dateKey);
      await prefs.setStringList(_processedDatesKey, dates);
    }
  }

  static Future<List<TowerDay>> getTowerDays() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getStringList(_towerKey);

    if (data == null) {
      return [];
    }

    return data
        .map(
          (item) => TowerDay.fromJson(
            jsonDecode(item),
          ),
        )
        .toList();
  }

  // Save a copy of the tower before it collapses.
  static Future<void> saveFallenTower(
    List<TowerDay> days,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final data = days
        .map((day) => jsonEncode(day.toJson()))
        .toList();

    await prefs.setStringList(
      _fallenTowerKey,
      data,
    );
  }

  static Future<List<TowerDay>> getFallenTower() async {
    final prefs = await SharedPreferences.getInstance();

    final data =
        prefs.getStringList(_fallenTowerKey);

    if (data == null) {
      return [];
    }

    return data
        .map(
          (item) => TowerDay.fromJson(
            jsonDecode(item),
          ),
        )
        .toList();
  }

  static Future<void> clearTower() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_towerKey);
  }

  static Future<void> clearFallenTower() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_fallenTowerKey);
  }

  static Future<void> resetTowerForTesting() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.remove('goal_minutes');
  await prefs.remove('tower_days');
  await prefs.remove('fallen_tower_days');

  await prefs.remove('journal_drafts_by_date');
  await prefs.remove('processed_tower_dates');
  await prefs.remove('last_processed_tower_date');
 }  
}