import 'package:flame/components/component.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

class Flare extends SpriteComponent {
  double _alpha = 1;

  Flare() : super.fromSprite(16, 16, Sprite("flare.png"));

  @override
  void update(double t) {
    super.update(t);

    _alpha -= t * 8;

    if (_alpha < 0) _alpha = 0;

    sprite.paint.color = Colors.black.withOpacity(_alpha);
    double s = 300;

    width += s * t;
    height += s * t;

    x -= s * 0.5 * t;
    y -= s * 0.5 * t;
  }

  @override
  bool destroy() {
    return _alpha <= 0;
  }
}
