import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flameblasterfaster/components/ships/player.dart';
import 'package:flameblasterfaster/components/should_destory.dart';
import 'package:flameblasterfaster/helpers/numberhelper.dart';
import 'package:flameblasterfaster/physics/collideable.dart';

abstract class PowerUp extends SpriteComponent
    implements Collidable, ShouldDestroy {
  final double _start;
  late Vector2 _size;
  bool _consumed = false;

  PowerUp(String skin)
      : _start = NumberHelper.random,
        super.fromImage(
          Flame.images.fromCache(skin),
          size: Vector2(28.0, 28.0),
        );

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    _size = size;

    x = _start * size.x - width * 0.5;
  }

  @override
  void update(double t) {
    y += t * 200;

    super.update(t);
  }

  @override
  bool get destroy {
    bool destroy = false;

    if (!destroy && ((y > _size.y) || _consumed)) {
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
