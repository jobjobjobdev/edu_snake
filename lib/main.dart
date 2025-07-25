import 'package:edu_snake/game_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const SnakeGame1D());
}

class SnakeGame1D extends StatelessWidget {
  const SnakeGame1D({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GamePage(),
    );
  }
}
