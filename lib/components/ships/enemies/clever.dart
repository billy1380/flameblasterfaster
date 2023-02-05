import 'package:flameblasterfaster/components/ships/enemies/enemy.dart';
import 'package:flameblasterfaster/components/ships/ship.dart';

class Clever extends Enemy {
  Clever(Fired onFire)
      : super("enemy_clever.png",
            weaponName: "laser_enemy.png",
            onFire: onFire,
            fireRate: 1,
            armour: 2) {
    maxSpeed.x = 2;
    maxSpeed.y = 5;
  }

  @override
  void update(double dt) {
    if (x == max.x) {
      move(0, stearTo.y);
    } else if (x == 0) {
      move(max.x + width, stearTo.y);
    }

    super.update(dt);
  }
}
