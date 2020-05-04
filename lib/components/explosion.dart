import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

class Explosion extends SpriteComponent {
  double _alpha = 1;

  Explosion() : super.fromSprite(64, 64, Sprite("explosion.png")) {
    Flame.audio.play("explosion.wav");
  }

  @override
  void update(double t) {
    super.update(t);

    _alpha -= t * 8;

    if (_alpha < 0) _alpha = 0;

    sprite.paint.color = Colors.black.withOpacity(_alpha);
    double s = 1600;

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
