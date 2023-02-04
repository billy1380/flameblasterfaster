import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flameblasterfaster/components/should_destory.dart';
import 'package:flameblasterfaster/physics/collideable.dart';

typedef Fired = void Function(Ship ship, String weapon, double elevated);

abstract class Ship extends SpriteComponent
    implements Collidable, ShouldDestroy {
  final Vector2 maxSpeed = Vector2(8, 0);

  final Vector2 max = Vector2.zero();
  final Vector2 stearTo = Vector2.zero();

  final String? weaponName;
  final double? fireRate;
  double _timeToNextFire;

  Fired? onFire;
  int _armour;
  final int _maxArmour;

  bool canLeaveX = false;
  bool canLeaveY = false;

  Ship(
    String skin, {
    required this.onFire,
    required this.weaponName,
    int armour = 2,
    int maxArmour = 2,
    this.fireRate = 0.3,
  })  : _maxArmour = maxArmour,
        _timeToNextFire = fireRate ?? 0,
        _armour = armour,
        super.fromImage(
          Flame.images.fromCache(skin),
          size: Vector2(64.0, 64.0),
        );

  int get health => _armour;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    max.x = size.x - width;
    max.y = size.y - height;
  }

  void move(double dx, double dy) {
    stearTo.x = dx;
    stearTo.y = dy;
  }

  @override
  void update(double t) {
    super.update(t);

    double finalX = stearTo.x - (width * 0.5);
    double finalY = stearTo.y - (height * 0.5);

    if (x > finalX) {
      x -= maxSpeed.x;
    } else if (x < finalX) {
      x += maxSpeed.x;
    }

    if ((x - finalX).abs() < maxSpeed.x) {
      x = finalX;
    }

    if (!canLeaveX) {
      if (x > max.x) {
        x = max.x;
      } else if (x < 0) {
        x = 0;
      }
    }

    if (y > finalY) {
      y -= maxSpeed.y;
    } else if (y < finalY) {
      y += maxSpeed.y;
    }

    if ((y - finalY).abs() < maxSpeed.y) {
      y = finalY;
    }

    if (!canLeaveY) {
      if (y > max.y) {
        y = max.y;
      } else if (y < 0) {
        y = 0;
      }
    }

    if (this.onFire != null && this.weaponName != null) {
      _timeToNextFire -= t;

      if (_timeToNextFire <= 0) {
        fire();
        _timeToNextFire = fireRate ?? 0;
      }
    }
  }

  void stop() {
    stearTo.x = x + (width * .5);
    stearTo.y = y + (height * .5);
  }

  void fire() {
    if (onFire != null && weaponName != null) {
      onFire!(this, weaponName!, 1);
    }
  }

  get isDead {
    return _armour <= 0;
  }

  void hurt() {
    _armour--;

    if (isDead) {
      _armour = 0;
    }
  }

  void heal() {
    _armour++;

    if (_armour > _maxArmour) {
      _armour = _maxArmour;
    }
  }

  @override
  Rect get frame => toRect();

  @override
  bool intersects(Collidable c) {
    Rect intersect = frame.intersect(c.frame);
    return intersect.width > 0 && intersect.height > 0;
  }

  @override
  bool get destroy {
    return isDead;
  }
}
