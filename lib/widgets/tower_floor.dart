import 'package:flutter/material.dart';

class TowerFloor extends StatelessWidget {
  final VoidCallback? onTap;

  const TowerFloor({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        width: 150, 
        height: 48,

        margin: const EdgeInsets.symmetric(vertical: 2),

        decoration: BoxDecoration(
          color: const Color(0xFFE8A06A),

          borderRadius: BorderRadius.circular(6),

          border: Border.all(
            color: const Color(0xFF8C5A3C),
            width: 2,
          ),

          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,

          children: [
            _window(),
            _window(),
            _window(),
          ],
        ),
      ),
    );
  }

  Widget _window() {
    return Container (
      width: 18, 
      height: 22,

      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 30, 133, 177),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}