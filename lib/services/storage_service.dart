import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/tower_day.dart';

class StorageService {
  static const String _goalKey = 'goal_minutes';
  static const String _towerKey = 'tower_days';

  static Future<void> saveGoal(int minutes) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(
      _goalKey,
      minutes,
    );
  }

  static Future<int?> getGoal() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getInt(_goalKey);
  }

  static Future<void> saveTowerDays(
    List<TowerDay> days,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final data = days.map((day) => jsonEncode(day.toJson())).toList();

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

    return data.map((item) => TowerDay.fromJson(jsonDecode(item),),).toList();
  }

  static Future<void> clearTower() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_towerKey);
  }
  }