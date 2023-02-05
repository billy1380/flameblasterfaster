import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flameblasterfaster/components/should_destory.dart';

class Flare extends SpriteComponent implements ShouldDestroy {
  Flare()
      : super.fromImage(
          Flame.images.fromCache("flare.png"),
          size: Vector2(16, 16),
        );

  @override
  void update(double dt) {
    super.update(dt);

    opacity = max(0, opacity - (dt * 8));

    double s = 300;

    width += s * dt;
    height += s * dt;

    x -= s * 0.5 * dt;
    y -= s * 0.5 * dt;
  }

  @override
  bool get destroy {
    return opacity <= 0;
  }
}
