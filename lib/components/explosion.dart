import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flameblasterfaster/components/should_destory.dart';
import 'package:flameblasterfaster/game/audio_manager.dart';

class Explosion extends SpriteComponent implements ShouldDestroy {
  Explosion()
    : super.fromImage(
        Flame.images.fromCache("explosion.png"),
        size: Vector2(64, 64),
      ) {
    AudioManager.play("explosion.wav");
  }

  @override
  void update(double dt) {
    super.update(dt);

    opacity = max(0, opacity - (dt * 8));

    if (opacity < 0) opacity = 0;

    double s = 1600;

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
