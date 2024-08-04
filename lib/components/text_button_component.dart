import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/input.dart';
import 'package:flameblasterfaster/components/fonts.dart';
import 'package:flutter/material.dart';

class TextButtonComponent extends ButtonComponent {
  TextButtonComponent({
    required String label,
    super.onPressed,
    super.position,
  }) : super(
            button: SpriteComponent.fromImage(
              Flame.images.fromCache("button_normal.png"),
              scale: Vector2.all(2),
              autoResize: true,
            ),
            buttonDown: SpriteComponent.fromImage(
              Flame.images.fromCache("button_pressed.png"),
              scale: Vector2.all(2),
              autoResize: true,
            ),
            size: Flame.images.fromCache("button_pressed.png").size * 2,
            anchor: Anchor.center) {
    TextComponent<TextPaint> t;
    add(t = TextComponent(
      text: label,
      priority: 1,
      textRenderer: Fonts.display,
    ));

    t.position.x = (scaledSize.x * .5) - (t.width * .5);
  }
}
