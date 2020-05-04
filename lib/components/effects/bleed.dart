import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/position.dart';
import 'package:flutter/material.dart';

class Bleed extends Component {
  double _duration = 1;
  double _alpha = 0.4;
  final Position camera;

  Size _size;

  Bleed(this.camera, this._duration);

  @override
  void resize(Size size) {
    super.resize(size);

    _size = size;
  }

  @override
  void render(Canvas c) {
    Paint p = Paint();
    p.color = Colors.red.withOpacity(_alpha);
    c.drawRect(Rect.fromLTRB(camera.x, camera.y, _size.width, _size.height), p);
  }

  @override
  void update(double dt) {
    _duration -= dt * 10;
    _alpha = _duration * 0.4;
  }

  @override
  bool destroy() {
    return _duration <= 0;
  }

  @override
  int priority() {
    return 99;
  }
}
