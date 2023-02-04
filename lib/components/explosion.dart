import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flameblasterfaster/components/should_destory.dart';

class Explosion extends SpriteComponent implements ShouldDestroy {
  Explosion()
      : super.fromImage(Flame.images.fromCache("explosion.png"),
            size: Vector2(64, 64)) {
    FlameAudio.play("explosion.wav");
  }

  @override
  void update(double t) {
    super.update(t);

    opacity = max(0, opacity - (t * 8));

    if (opacity < 0) opacity = 0;

    double s = 1600;

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
