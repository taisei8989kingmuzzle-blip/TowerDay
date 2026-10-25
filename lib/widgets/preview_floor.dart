import 'package:flutter/material.dart';

class PreviewFloor extends StatelessWidget {
  final int floorNumber;
  final VoidCallback onTap;

  const PreviewFloor({
    super.key,
    required this.floorNumber,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 6,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Opacity(
            opacity: 0.45,
            child: Container(
              width: 190,
              height: 62,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE8D2),
                border: Border.all(
                  color: const Color(0xFF9B765D),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Floor $floorNumber · Today',
                      style: const TextStyle(
                        color: Color(0xFF6F4935),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Tap to write your journal',
                      style: TextStyle(
                        color: Color(0xFF6F4935),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}