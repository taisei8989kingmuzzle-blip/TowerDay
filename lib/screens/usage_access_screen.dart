import 'package:flutter/material.dart';

import '../services/screen_time_service.dart';

class UsageAccessScreen extends StatefulWidget {
  const UsageAccessScreen({super.key});

  @override
  State<UsageAccessScreen> createState() =>
      _UsageAccessScreenState();
}

class _UsageAccessScreenState
    extends State<UsageAccessScreen> {

  final ScreenTimeService _screenTimeService =
      ScreenTimeService();

  bool checking = false;

  Future<void> _grantAccess() async {
    await _screenTimeService.openUsageAccessSettings();

    if (!mounted) return;

    setState(() {
      checking = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    final hasAccess =
        await _screenTimeService.hasUsageAccess();

    if (!mounted) return;

    setState(() {
      checking = false;
    });

    if (hasAccess) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen-Time Access'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [

            const Text(
              '📱',
              style: TextStyle(
                fontSize: 64,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Screen-time access',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'My Little Tower needs access to your '
              'device usage statistics so it can check '
              'whether you stayed under your daily '
              'screen-time goal.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Your usage data is used only to calculate '
              'your screen-time total on this device. '
              'The app does not need to send your '
              'app-usage history to a server.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 35),

            FilledButton(
              onPressed: checking
                  ? null
                  : _grantAccess,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                child: Text(
                  checking
                      ? 'Checking...'
                      : 'Grant Screen-Time Access',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}