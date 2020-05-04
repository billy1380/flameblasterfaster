import 'package:flame/components/particle_component.dart';
import 'package:flame/particle.dart';
import 'package:flame/particles/moving_particle.dart';
import 'package:flame/particles/sprite_particle.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flameblasterfaster/helpers/numberhelper.dart';
import 'package:flutter/material.dart';

class SmokeParticle extends SpriteParticle {
  double _alpha = NumberHelper.random;
  SmokeParticle()
      : super(
          sprite: Sprite(
            "smoke.png",
          ),
          size: _size(),
        );
  static Position _size() {
    double s = 64 * NumberHelper.random;
    return Position(s, s);
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
    sprite.paint.color = Colors.black.withOpacity(_alpha);
    super.render(canvas);
  }
}

class Smoke extends ParticleComponent {
  Smoke(x, y)
      : super(
            particle: Particle.generate(
                count: 30,
                generator: (i) => MovingParticle(
                      child: SmokeParticle(),
                      from: Offset(x, y),
                      to: Offset(x + 100 * (NumberHelper.random - 0.5),
                          y + 100 * (NumberHelper.random - 0.5)),
                      lifespan: 10000,
                    )));
}
