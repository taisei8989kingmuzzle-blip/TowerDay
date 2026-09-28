import 'package:flutter/material.dart';
import 'tower_floor.dart';

class Tower extends StatelessWidget {
  final int floorCount;
  final VoidCallback? onFloorTap;

  const Tower ({
    super.key,
    required this.floorCount,
    this.onFloorTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,

      children: [
        for (int i = 0; i < floorCount; i++)
          TowerFloor(
            onTap: onFloorTap,
          ),

          Container(
            width: 190,
            height: 25,

            decoration: BoxDecoration(
              color: const Color(0xFF8C5A3C),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
      ],
    );
  }
}