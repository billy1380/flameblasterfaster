import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flameblasterfaster/components/ships/enemies/enemy.dart';
import 'package:flameblasterfaster/components/ships/player.dart';
import 'package:flameblasterfaster/components/should_destory.dart';
import 'package:flameblasterfaster/physics/collideable.dart';

class Bullet extends SpriteComponent implements Collidable, ShouldDestroy {
  double speed = 1000;
  final bool up;
  late Vector2 _size;
  String skin;
  bool _hit = false;

  Bullet(
    this.skin, {
    this.up = true,
  }) : super.fromImage(
          Flame.images.fromCache(skin),
          size: Vector2(32, 32),
        ) {
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
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _size = size;
  }

  @override
  void update(double t) {
    super.update(t);

    y = y + (t * speed) * (up ? -1 : 1);
  }

  @override
  bool get destroy {
    bool destroy = false;

    if (!destroy && ((up && y < -height) || (!up && y > _size.x) || _hit)) {
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
