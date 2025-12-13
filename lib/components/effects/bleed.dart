import 'package:flame/components.dart';
import 'package:flameblasterfaster/components/should_destory.dart';
import 'package:flutter/material.dart';

class Bleed extends Component implements ShouldDestroy {
  double _duration = 1;
  double _alpha = 0.4;

  final CameraComponent camera;
  late Vector2 _size;

  Bleed(this.camera, this._duration) : super(priority: 99);

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    _size = size;
  }

  @override
  void render(Canvas canvas) {
    Paint p = Paint();
    p.color = Colors.red.withOpacity(_alpha);
    canvas.drawRect(
      Rect.fromLTRB(
        camera.viewport.position.x,
        camera.viewport.position.y,
        _size.x,
        _size.y,
      ),
      p,
    );
  }

  @override
  void update(double dt) {
    _duration -= dt * 10;
    _alpha = _duration * 0.4;

    if (_alpha < 0) {
      _alpha = 0;
    }
  }

  @override
  bool get destroy {
    return _duration <= 0;
  }
}
