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
  void update(double t) {
    super.update(t);

    opacity = max(0, opacity - (t * 8));

    double s = 300;

    width += s * t;
    height += s * t;

    x -= s * 0.5 * t;
    y -= s * 0.5 * t;
  }

  @override
  bool get destroy {
    return opacity <= 0;
  }
}
