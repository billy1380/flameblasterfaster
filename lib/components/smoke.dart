import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/particles.dart';

import 'package:flameblasterfaster/helpers/numberhelper.dart';
import 'package:flutter/material.dart';

class SmokeParticle extends SpriteParticle {
  double _alpha = NumberHelper.random;
  SmokeParticle()
      : super(
          sprite: Sprite(Flame.images.fromCache("smoke.png")),
          size: _size(),
        );
  static Vector2 _size() {
    double s = 64 * NumberHelper.random;
    return Vector2(s, s);
  }

  @override
  void update(double dt) {
    _alpha -= dt * 2;

    if (_alpha < 0) {
      _alpha = 0;
    }

    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    sprite.paint.color = Colors.white.withOpacity(_alpha);
    super.render(canvas);
  }
}

class Smoke extends ParticleSystemComponent {
  Smoke(x, y)
      : super(
          particle: Particle.generate(
            count: 30,
            generator: (i) => MovingParticle(
              child: SmokeParticle(),
              from: Vector2(x, y),
              to: Vector2(x + 100 * (NumberHelper.random - 0.5),
                  y + 100 * (NumberHelper.random - 0.5)),
              lifespan: 10000,
            ),
          ),
        );
}
