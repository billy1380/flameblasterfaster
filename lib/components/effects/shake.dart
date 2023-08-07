import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flameblasterfaster/components/should_destory.dart';
import 'package:flameblasterfaster/helpers/numberhelper.dart';
import 'package:flutter/material.dart';

class Shake extends Component implements ShouldDestroy {
  double duration;
  double intensity;
  final Camera camera;

  Shake(
    this.camera, {
    this.duration = 1,
    this.intensity = 100,
  });

  @override
  void render(Canvas canvas) {}

  @override
  void update(double dt) {
    duration -= dt * 10;

    if (duration <= 0) {
      camera.position.x = 0;
      camera.position.y = 0;
    } else {
      camera.position.x = (NumberHelper.random - 0.5) * intensity;
      camera.position.y = (NumberHelper.random - 0.5) * intensity;
    }
  }

  @override
  bool get destroy {
    return duration <= 0;
  }
}
