import 'package:flutter/material.dart';

class PlantImage extends StatelessWidget {
  final int points;
  const PlantImage({super.key, required this.points});

  String _getImagePath() {
    if (points <= 1) return 'lib/assets/px10.png';
    if (points == 2) return 'lib/assets/px9.png';
    if (points == 3) return 'lib/assets/px8.png';
    if (points == 4) return 'lib/assets/px7.png';
    if (points == 5) return 'lib/assets/px6.png';
    return 'lib/assets/px5.png';
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: 300,
        color: Colors.red,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Image.asset(
            _getImagePath(),
            key: ValueKey(_getImagePath()),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
