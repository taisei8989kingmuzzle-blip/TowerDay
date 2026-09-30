import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ScreenTimeService {
  static const MethodChannel _channel =
      MethodChannel('my_little_tower/screen_time');

  // Demo mode lets us test the app without an Android phone.
  static bool demoMode = true;

  // Default simulated screen time.
  static int demoMinutes = 120;

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

  Future<int> getTodayScreenTimeMinutes() async {
    if (demoMode || kIsWeb) {
      return demoMinutes;
    }

    final result = await _channel.invokeMethod<int>(
      'getTodayScreenTime',
    );

    return result ?? 0;
  }

  // Development/demo helper.
  void setDemoMinutes(int minutes) {
    demoMinutes = minutes;
  }
}