import 'package:flutter/material.dart';

class LevelBar extends StatelessWidget {
  final int score;

  const LevelBar({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    final int remainder = score % 10;
    final double fillFactor = remainder / 10;
    return Container(
      height: 10,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        color: Colors.grey[800],
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: fillFactor,
          child: Container(color: Colors.green),
        ),
      ),
    );
  }
}
