import 'package:flame/components/component.dart';
import 'package:flame/sprite.dart';
import 'package:flameblasterfaster/physics/collideable.dart';
import 'package:flameblasterfaster/helpers/numberhelper.dart';
import 'package:flameblasterfaster/components/ships/player.dart';
import 'package:flutter/material.dart';

abstract class PowerUp extends SpriteComponent implements Collidable {
  final double _start;
  Size _size;
  bool _consumed = false;

  PowerUp(String skin)
      : _start = NumberHelper.random,
        super.fromSprite(28.0, 28.0, Sprite(skin));

  @override
  void resize(Size size) {
    super.resize(size);

    _size = size;

    x = _start * size.width - width * 0.5;
  }

  @override
  void update(double t) {
    y += t * 200;

    super.update(t);
  }

  @override
  bool destroy() {
    bool destroy = super.destroy();

    if (!destroy && (y > _size.height || _consumed)) {
      destroy = true;
    }

    return destroy;
  }

  @override
  Rect get frame => toRect();

  @override
  bool intersects(Collidable c) {
    Rect intersect = frame.intersect(c.frame);
    return intersect.width > 0 && intersect.height > 0;
  }

  @override
  void hit(Collidable c) {
    if (c is Player) {
      _consumed = true;
    }
  }
}
