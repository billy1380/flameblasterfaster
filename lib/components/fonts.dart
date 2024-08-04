import 'package:flame/components.dart';
import 'package:flutter/material.dart';

abstract class Fonts {
  static TextPaint display = TextPaint(
    style: const TextStyle(
      fontSize: 32,
      color: Colors.white,
      fontFamily: "m5x7",
    ),
  );

  Fonts._();
}
