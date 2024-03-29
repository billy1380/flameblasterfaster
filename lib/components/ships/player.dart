import 'package:flame/extensions.dart';
import 'package:flameblasterfaster/components/bullet.dart';
import 'package:flameblasterfaster/components/powerups/armour.dart';
import 'package:flameblasterfaster/components/powerups/laser.dart';
import 'package:flameblasterfaster/components/ships/enemies/enemy.dart';
import 'package:flameblasterfaster/components/ships/ship.dart';
import 'package:flameblasterfaster/game/audio_manager.dart';
import 'package:flameblasterfaster/physics/collideable.dart';

class Player extends Ship {
  double _elevatedFirePower = 0;

  Player(Fired onFire)
      : super(
          "ship.png",
          weaponName: "laser_ship.png",
          onFire: onFire,
          armour: 4,
          maxArmour: 4,
        );

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    x = (size.x - width) * 0.5;

    y = size.y - height * 2;

    stop();
  }

  @override
  void fire() {
    if (onFire != null && weaponName != null) {
      onFire!(this, weaponName!, _elevatedFirePower);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    _elevatedFirePower -= dt;

    if (_elevatedFirePower < 0) {
      _elevatedFirePower = 0;
    }
  }

  @override
  void hit(Collidable c) {
    if (c is Enemy) {
      hurt();
    } else if (c is Armour) {
      heal();
      AudioManager.play("powerup.wav");
    } else if (c is Laser) {
      _elevatedFirePower = 10;
      AudioManager.play("powerup.wav");
    } else if (c is Bullet && c.skin.contains("_enemy")) {
      hurt();
    }
  }

  @override
  void hurt() {
    super.hurt();

    AudioManager.play("hit_ship.wav");
  }
}
