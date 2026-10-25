import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ScreenTimeService {
  static const MethodChannel _channel =
      MethodChannel('my_little_tower/screen_time');

  // Demo mode lets us test the app without an Android phone.
  //turn it into false when actually implementing the actual app
  static bool demoMode = false;

  // Default simulated screen time.
  static int demoMinutes = 120;

  void setDemoMinutes(int minutes) {
    demoMinutes = minutes;
    demoMode = true;
  }

  void disableDemoMode() {
    demoMode = false;
  }

  Future<bool> hasUsageAccess() async {
    if (demoMode || kIsWeb) {
      return true;
    }

    final result = await _channel.invokeMethod<bool>(
      'hasUsageAccess',
    );

    return result ?? false;
  }

  Future<void> openUsageAccessSettings() async {
    if (demoMode || kIsWeb) {
      return;
    }

    await _channel.invokeMethod(
      'openUsageAccessSettings',
    );
  }

  Future<int> getScreenTimeMinutes() {
    return getScreenTimeForDate(DateTime.now());
  }

  Future<int> getScreenTimeForDate(DateTime date) async {
    if (demoMode || kIsWeb) {
      return demoMinutes;
    }

    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    final result = await _channel.invokeMethod<int>(
      'getScreenTimeForDate',
      {
        'startMillis': start.millisecondsSinceEpoch,
        'endMillis': end.millisecondsSinceEpoch,
      },
    );

    if (result == null || result < 0) {
      throw PlatformException(
        code: 'INVALID_SCREEN_TIME',
        message: 'Could not retrieve screen time for $date.',
      );
    }

    return result;
  }
  Future<int> getTodayScreenTimeMinutes() {
   return getScreenTimeForDate(DateTime.now());
  }

  // Development/demo helper.
 
}