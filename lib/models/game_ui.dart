import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GameUI {
  static TextComponent score() => TextComponent(
        text: 'Score: 0',
        position: Vector2(20, 80),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.red,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
}
