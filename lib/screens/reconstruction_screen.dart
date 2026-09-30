import 'package:flutter/material.dart';

import '../services/revenuecat_service.dart';

class ReconstructionScreen
    extends StatefulWidget {
  final Future<void> Function()
      onPurchaseComplete;

  const ReconstructionScreen({
    super.key,
    required this.onPurchaseComplete,
  });

  @override
  State<ReconstructionScreen> createState() =>
      _ReconstructionScreenState();
}

class _ReconstructionScreenState
    extends State<ReconstructionScreen> {
  bool purchasing = false;

  Future<void> _reconstruct() async {
    if (purchasing) return;

    setState(() {
      purchasing = true;
    });

    try {
      final success =
          await RevenueCatService
              .purchaseReconstruction();

      if (!mounted) return;

      if (success) {
        await widget.onPurchaseComplete();

        if (!mounted) return;

        Navigator.pop(context);
        return;
      }

      setState(() {
        purchasing = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Reconstruction was cancelled.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        purchasing = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Test purchase failed: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tower Reconstruction',
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Text(
                '🏰',
                style: TextStyle(
                  fontSize: 90,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Reconstruct Your Tower',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6F4935),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Your previous floors have been '
                'preserved.\n\n'
                'Use Tower Reconstruction to '
                'restore the tower you built before '
                'the collapse.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 30),

              FilledButton(
                onPressed:
                    purchasing
                        ? null
                        : _reconstruct,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  child: Text(
                    purchasing
                        ? 'Opening Test Store...'
                        : 'Reconstruct Tower',
                  ),
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                'RevenueCat Test Store • No real charge',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}