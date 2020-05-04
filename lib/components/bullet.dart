import 'package:flame/components/component.dart';
import 'package:flame/sprite.dart';
import 'package:flameblasterfaster/components/ships/enemies/enemy.dart';
import 'package:flameblasterfaster/components/ships/player.dart';
import 'package:flameblasterfaster/physics/collideable.dart';
import 'package:flutter/material.dart';

class Bullet extends SpriteComponent implements Collidable {
  double speed = 1000;
  final bool up;
  Size _size;
  String skin;
  bool _hit = false;

  Bullet(this.skin, {this.up = true}) : super.fromSprite(32, 32, Sprite(skin)) {
    width *= 0.5;
    height *= 0.5;
  }

  bool get isEnemy {
    return skin.contains("_enemy");
  }

  bool get isPlayer {
    return skin.contains("_ship");
  }

  @override
  void resize(Size size) {
    _size = size;
  }

  @override
  void update(double t) {
    super.update(t);

    y = y + (t * speed) * (up ? -1 : 1);
  }

  @override
  bool destroy() {
    bool destroy = super.destroy();

    if (!destroy &&
        ((up && y < -height) || (!up && y > _size.height) || _hit)) {
      destroy = true;
    }

    return destroy;
  }

  @override
  Rect get frame => toRect();

  @override
  void hit(Collidable c) {
    if (c is Enemy && isPlayer) {
      _hit = true;
    } else if (c is Player && isEnemy) {
      _hit = true;
    }
  }

  @override
  bool intersects(Collidable c) {
    Rect intersect = frame.intersect(c.frame);
    return intersect.width > 0 && intersect.height > 0;
  }
}
