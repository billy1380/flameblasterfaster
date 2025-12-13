import "package:flameblasterfaster/components/ships/enemies/enemy.dart";

class Kamikaze extends Enemy {
  Kamikaze() : super("enemy_kamikaze.png", armour: 2) {
    maxSpeed.y = 10;
  }
}
