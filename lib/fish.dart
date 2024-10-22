import 'package:flutter/material.dart';

class Fish {
  Offset position;
  Color color;
  double speed;

  Fish({
    required this.position,
    required this.color,
    required this.speed,
  });
}

class FishWidget extends StatelessWidget {
  final Fish fish;

  FishWidget({required this.fish});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: fish.position.dx,
      top: fish.position.dy,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: fish.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

