import 'package:flame/components/text_component.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/material.dart';

class Score extends TextComponent {
  int _score = 0;
  Sprite _background;
  Position _backgroundPosition;

  Score() : super(0.toString().padLeft(6, "0")) {
    config = TextConfig(fontSize: 32, color: Colors.white, fontFamily: "m5x7");
    _background = Sprite("score.png");
    _backgroundPosition = this.toPosition();
  }

  @override
  void resize(Size size) {
    super.resize(size);

    x = size.width - width - 10;
    y = 10;
  }

  void increment(int by) {
    _score += by;

    this.text = _score.toString().padLeft(6, "0");
  }

  @override
  set x(double value) {
    super.x = value - 10;
    _backgroundPosition.x = value - 22;
  }

  @override
  set y(double value) {
    super.y = value + 8;
    _backgroundPosition.y = value + 8;
  }

  @override
  bool isHud() {
    return true;
  }

  @override
  void render(Canvas c) {
    _background.renderScaled(c, _backgroundPosition, scale: 2);
    super.render(c);
  }

  @override
  int priority() {
    return 100;
  }
}
