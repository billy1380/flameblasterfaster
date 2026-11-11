import "dart:ui";

import "package:flame/components.dart";
import "package:flame/events.dart";
import "package:flame/flame.dart";
import "package:flameblasterfaster/game/audio_manager.dart";

class MuteButton extends PositionComponent with TapCallbacks {
  static const double _pixel = 2;

  static final Paint _on = Paint()..color = const Color(0xFFFFFFFF);
  static final Paint _off = Paint()..color = const Color(0xFFff5a5a);

  late final Sprite _normal;
  late final Sprite _pressed;
  bool _down = false;

  MuteButton()
      : super(
          size: Vector2(40, 32),
          anchor: Anchor.topRight,
          priority: 100,
        );

  @override
  Future<void> onLoad() async {
    _normal = Sprite(Flame.images.fromCache("button_normal.png"));
    _pressed = Sprite(Flame.images.fromCache("button_pressed.png"));
  }

  @override
  void render(Canvas canvas) {
    (_down ? _pressed : _normal).render(canvas, size: size);

    final bool muted = AudioManager.muted;
    final double dy = _down ? _pixel : 0;

    void px(double x, double y, double w, double h, Paint paint) {
      canvas.drawRect(
        Rect.fromLTWH(
          10 + x * _pixel,
          6 + dy + y * _pixel,
          w * _pixel,
          h * _pixel,
        ),
        paint,
      );
    }

    px(0, 3, 3, 4, _on);
    px(3, 2, 1, 6, _on);
    px(4, 1, 1, 8, _on);

    if (muted) {
      for (final (double, double) p in [
        (6, 3), (9, 3), (7, 4), (8, 4), (7, 5), (8, 5), (6, 6), (9, 6), //
      ]) {
        px(p.$1, p.$2, 1, 1, _off);
      }
    } else {
      px(6, 3, 1, 4, _on);
      px(8, 2, 1, 6, _on);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    _down = true;

    if (AudioManager.muted) {
      AudioManager.unmute();
    } else {
      AudioManager.mute();
    }
  }

  @override
  void onTapCancel(TapCancelEvent event) => _down = false;

  @override
  void onTapUp(TapUpEvent event) => _down = false;
}
