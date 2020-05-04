import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/position.dart';
import 'package:flameblasterfaster/helpers/numberhelper.dart';
import 'package:flutter/material.dart';

class Shake extends Component {
  double duration;
  double intensity = 100;
  final Position camera;

  Shake(this.camera, {this.duration = 1, this.intensity});

  @override
  void render(Canvas c) {}

  @override
  void update(double dt) {
    duration -= dt * 10;

    if (duration <= 0) {
      camera.x = 0;
      camera.y = 0;
    } else {
      camera.x = (NumberHelper.random - 0.5) * intensity;
      camera.y = (NumberHelper.random - 0.5) * intensity;
    }
  }

  @override
  bool destroy() {
    return duration <= 0;
  }
}
