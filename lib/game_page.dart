import 'dart:async';
import 'dart:math';

import 'package:edu_snake/level_bar.dart';
import 'package:edu_snake/plant_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum Direction { up, down, left, right }

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final int rows = 20;
  final int cols = 20;
  late List<int> snakePositions;
  late Direction direction;
  late Timer timer;
  late int foodPosition;
  final Random random = Random();

  final FocusNode _focusNode = FocusNode();
  bool directionChanged = false;

  @override
  void initState() {
    super.initState();
    direction = Direction.right;
    snakePositions = [0, 1, 2];
    spawnFood();
    timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      moveSnake();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void spawnFood() {
    List<int> freePositions = List.generate(
      rows * cols,
      (i) => i,
    ).where((pos) => !snakePositions.contains(pos)).toList();
    if (freePositions.isEmpty) {
      timer.cancel();
      return;
    }
    foodPosition = freePositions[random.nextInt(freePositions.length)];
  }

  void moveSnake() {
    setState(() {
      int head = snakePositions.last;
      int nextPos;

      switch (direction) {
        case Direction.right:
          nextPos = head + 1;
          if (nextPos % cols == 0) nextPos -= cols;
          break;
        case Direction.left:
          nextPos = head - 1;
          if (nextPos < 0 || nextPos % cols == cols - 1) nextPos += cols;
          break;
        case Direction.up:
          nextPos = head - cols;
          if (nextPos < 0) nextPos += rows * cols;
          break;
        case Direction.down:
          nextPos = head + cols;
          if (nextPos >= rows * cols) nextPos -= rows * cols;
          break;
      }

      // if (snakePositions.contains(nextPos)) {
      //   timer.cancel();
      //   return;
      // }

      snakePositions.add(nextPos);

      if (nextPos == foodPosition) {
        spawnFood();
      } else {
        snakePositions.removeAt(0);
      }

      directionChanged = false;
    });
  }

  void restartGame() {
    timer.cancel();
    setState(() {
      direction = Direction.right;
      snakePositions = [0, 1, 2];
      directionChanged = false;
      spawnFood();
      timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
        moveSnake();
      });
    });
  }

  void changeDirection(Direction newDirection) {
    if (directionChanged) return;

    if ((direction == Direction.left && newDirection == Direction.right) ||
        (direction == Direction.right && newDirection == Direction.left) ||
        (direction == Direction.up && newDirection == Direction.down) ||
        (direction == Direction.down && newDirection == Direction.up)) {
      return;
    }

    setState(() {
      direction = newDirection;
      directionChanged = true;
    });
  }

  void handleKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey.keyLabel.toLowerCase()) {
        case 'w':
          changeDirection(Direction.up);
          break;
        case 's':
          changeDirection(Direction.down);
          break;
        case 'a':
          changeDirection(Direction.left);
          break;
        case 'd':
          changeDirection(Direction.right);
          break;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        changeDirection(Direction.up);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        changeDirection(Direction.down);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        changeDirection(Direction.left);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        changeDirection(Direction.right);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double boardSize = 200;
    return Scaffold(
      backgroundColor: Colors.black,
      body: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: handleKey,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {
                        restartGame();
                      },
                      child: const Text('Restart'),
                    ),
                  ],
                ),
              ),
              LevelBar(score: snakePositions.length - 3),
              Expanded(
                flex: 3,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [PlantImage(points: snakePositions.length - 3)],
                  ),
                ),
              ),

              //
              Column(
                children: [
                  SizedBox(
                    width: boardSize,
                    height: 50,
                    child: IconButton(
                      icon: const Icon(Icons.keyboard_arrow_up),
                      color: Colors.white,
                      onPressed: () => changeDirection(Direction.up),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 50,
                        height: boardSize,
                        child: IconButton(
                          icon: const Icon(Icons.keyboard_arrow_left),
                          color: Colors.white,
                          onPressed: () => changeDirection(Direction.left),
                        ),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: boardSize,
                          maxHeight: boardSize,
                        ),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: cols,
                              ),
                          itemCount: rows * cols,
                          itemBuilder: (context, index) {
                            bool isSnake = snakePositions.contains(index);
                            bool isFood = index == foodPosition;
                            return Container(
                              margin: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: isSnake
                                    ? Colors.green
                                    : isFood
                                    ? Colors.red
                                    : Colors.grey[900],
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width: 50,
                        height: boardSize,
                        child: IconButton(
                          icon: const Icon(Icons.keyboard_arrow_right),
                          color: Colors.white,
                          onPressed: () => changeDirection(Direction.right),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: boardSize,
                    height: 50,
                    child: IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down),
                      color: Colors.white,
                      onPressed: () => changeDirection(Direction.down),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
