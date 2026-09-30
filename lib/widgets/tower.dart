import 'package:flutter/material.dart';

import '../models/tower_day.dart';
import 'tower_floor.dart';

class Tower extends StatelessWidget {
  final List<TowerDay> days;
  final void Function(int index)? onFloorTap;

  const Tower({
    super.key,
    required this.days,
    this.onFloorTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        for (int i = 0; i < days.length; i++)
          TowerFloor(
            onTap: () {
              onFloorTap?.call(i);
            },
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