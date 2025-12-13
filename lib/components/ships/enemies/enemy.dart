import "package:flame/extensions.dart";
import "package:flameblasterfaster/components/bullet.dart";
import "package:flameblasterfaster/components/ships/player.dart";
import "package:flameblasterfaster/components/ships/ship.dart";
import "package:flameblasterfaster/game/audio_manager.dart";
import "package:flameblasterfaster/helpers/numberhelper.dart";
import "package:flameblasterfaster/physics/collideable.dart";

abstract class Enemy extends Ship {
  final double _start;
  bool firstX = true;

  Enemy(
    super.skin, {
    super.weaponName,
    super.onFire,
    super.fireRate,
    super.armour,
  }) : _start = NumberHelper.random {
    maxSpeed.x = 0;
    canLeaveY = true;
    y = -height;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    if (firstX) {
      x = max.x * _start;

      move(NumberHelper.random > 0.5 ? 0 : max.x + width, max.y + 100);

      firstX = false;
    }
  }

  @override
  bool get destroy {
    return super.destroy || (y > max.y + height);
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

    AudioManager.play("hit_enemy.wav");
  }
}
