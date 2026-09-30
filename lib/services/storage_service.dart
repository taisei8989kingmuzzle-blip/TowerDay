import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/tower_day.dart';

class StorageService {
  static const String _goalKey = 'goal_minutes';
  static const String _towerKey = 'tower_days';

  // Stores the tower that existed immediately before a collapse.
  static const String _fallenTowerKey = 'fallen_tower_days';

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

    await prefs.remove(_towerKey);
    await prefs.remove(_fallenTowerKey);
  }
}