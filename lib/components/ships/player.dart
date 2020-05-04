import 'package:flame/flame.dart';
import 'package:flameblasterfaster/components/bullet.dart';
import 'package:flameblasterfaster/components/powerups/armour.dart';
import 'package:flameblasterfaster/components/powerups/laser.dart';
import 'package:flameblasterfaster/components/ships/enemies/enemy.dart';
import 'package:flameblasterfaster/components/ships/ship.dart';
import 'package:flameblasterfaster/physics/collideable.dart';
import 'package:flutter/material.dart';

class Player extends Ship {
  double _elevatedFirePower = 0;

  Player(Fired onFire)
      : super("ship.png",
            weaponName: "laser_ship.png",
            onFire: onFire,
            armour: 4,
            maxArmour: 4);

  @override
  void resize(Size size) {
    super.resize(size);

    x = (size.width - width) * 0.5;

    y = size.height - height * 2;

    stop();
  }

  @override
  void fire() {
    onFire(this, weaponName, _elevatedFirePower);
  }

  @override
  void update(double t) {
    super.update(t);

    _elevatedFirePower -= t;
  }

  @override
  void hit(Collidable c) {
    if (c is Enemy) {
      hurt();
    } else if (c is Armour) {
      heal();
      Flame.audio.play("powerup.wav");
    } else if (c is Laser) {
      _elevatedFirePower = 10;
      Flame.audio.play("powerup.wav");
    } else if (c is Bullet && c.skin.contains("_enemy")) {
      hurt();
    }
  }

  @override
  void hurt() {
    super.hurt();

    Flame.audio.play("hit_ship.wav");
  }
}
