import 'package:flame/flame.dart';
import 'package:flameblasterfaster/components/bullet.dart';
import 'package:flameblasterfaster/components/ships/player.dart';
import 'package:flameblasterfaster/components/ships/ship.dart';
import 'package:flameblasterfaster/helpers/numberhelper.dart';
import 'package:flameblasterfaster/physics/collideable.dart';
import 'package:flutter/material.dart';

abstract class Enemy extends Ship {
  double _start;
  bool firstX = true;

  Enemy(String skin,
      {String weaponName, Fired onFire, double fireRate, int armour})
      : _start = NumberHelper.random,
        super(skin,
            weaponName: weaponName,
            onFire: onFire,
            fireRate: fireRate,
            armour: armour,
            maxArmour: armour) {
    maxSpeed.x = 0;
    canLeaveY = true;
    y = -height;
  }

  @override
  void resize(Size size) {
    super.resize(size);

    if (firstX) {
      x = max.x * _start;

      move(NumberHelper.random > 0.5 ? 0 : max.x + width, max.y + 100);

      firstX = false;
    }
  }

  @override
  bool destroy() {
    return super.destroy() || (y > max.y + height);
  }

  @override
  void hit(Collidable c) {
    if (c is Player) {
      hurt();
    } else if (c is Bullet && c.skin.contains("_ship")) {
      hurt();
    }
  }

  @override
  void hurt() {
    super.hurt();

    Flame.audio.play("hit_enemy.wav");
  }
}
