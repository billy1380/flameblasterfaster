import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/components/parallax_component.dart';
import 'package:flame/flame.dart';
import 'package:flame/game/base_game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/keyboard.dart';
import 'package:flameblasterfaster/components/bullet.dart';
import 'package:flameblasterfaster/components/effects/bleed.dart';
import 'package:flameblasterfaster/components/effects/shake.dart';
import 'package:flameblasterfaster/components/explosion.dart';
import 'package:flameblasterfaster/components/flare.dart';
import 'package:flameblasterfaster/components/hud/health.dart';
import 'package:flameblasterfaster/components/hud/score.dart';
import 'package:flameblasterfaster/components/powerups/armour.dart';
import 'package:flameblasterfaster/components/powerups/laser.dart';
import 'package:flameblasterfaster/components/ships/enemies/clever.dart';
import 'package:flameblasterfaster/components/ships/enemies/enemy.dart';
import 'package:flameblasterfaster/components/ships/enemies/kamikaze.dart';
import 'package:flameblasterfaster/components/ships/player.dart';
import 'package:flameblasterfaster/components/ships/ship.dart';
import 'package:flameblasterfaster/components/smoke.dart';
import 'package:flameblasterfaster/components/spawner.dart';
import 'package:flameblasterfaster/helpers/numberhelper.dart';
import 'package:flameblasterfaster/physics/collideable.dart';
import 'package:flameblasterfaster/physics/collisionprocessor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BlasterFaster extends BaseGame
    with KeyboardEvents, HorizontalDragDetector {
  // static final Logger _log = Logger("BlasterFaster");

  Player player;
  bool _stop = false;
  bool _pause = false;
  bool _start = false;

  final VoidCallback finished;

  Size _size = window.physicalSize;

  BlasterFaster(this.finished) {
    _addStars();
  }

  void start() {
    components
        .where((e) => !(e is ParallaxComponent))
        .forEach((e) => markToRemove(e));

    _addPlayer();

    addLater(Spawner(1, _addClever));
    addLater(Spawner(2, _addKamikaze));
    addLater(Spawner(10, _addPowerUp));

    addLater(Score());
    addLater(Health());

    _start = true;
    _stop = false;
  }

  @override
  void resize(Size size) {
    super.resize(size);

    _size = size;
  }

  void _addPlayer() {
    addLater(player = Player((a, b, c) {
      _addPrimaryBulets(a, b);

      if (c > 0) {
        _addSecondaryBulets(a, b);
      }

      Flame.audio.play("laser_ship.wav");
    }));
  }

  @override
  void update(double t) {
    super.update(t);

    if (_start) {
      if (!_stop) {
        List<Hit> hits = CollisionProcessor.process(this.components);

        for (Hit h in hits) {
          if ((h.a is Player &&
                  (h.b is Enemy ||
                      (h.b is Bullet && (h.b as Bullet).isEnemy))) ||
              (h.b is Player &&
                  (h.a is Enemy ||
                      (h.a is Bullet && (h.a as Bullet).isEnemy)))) {
            addLater(Shake(camera, duration: 3, intensity: 100));
            addLater(Bleed(camera, 1));
          }

          if ((h.a is Player && h.b is Bullet && (h.b as Bullet).isEnemy) ||
              (h.a is Enemy && h.b is Bullet && (h.b as Bullet).isPlayer) ||
              (h.b is Player && h.a is Bullet && (h.a as Bullet).isEnemy) ||
              (h.b is Enemy && h.a is Bullet && (h.a as Bullet).isPlayer)) {
            addLater(Flare()
              ..x = h.a.frame.topLeft.dx
              ..y = h.a.frame.topLeft.dy);
          }
        }

        Score score;
        Player player;
        Health health;

        int dead = 0;
        for (Component c in components) {
          if (c is Player) {
            player = c;
            if (!_stop) {
              _stop = c.isDead;

              if (_stop) {
                finished();
              }
            }

            if (c.isDead) {
              addLater(Explosion()
                ..x = c.frame.topLeft.dx
                ..y = c.frame.topLeft.dy);

              addLater(Smoke(c.frame.topLeft.dx, c.frame.topLeft.dy));
            }
          } else if (c is Score) {
            score = c;
          } else if (c is Health) {
            health = c;
          } else if (c is Enemy) {
            if (c.isDead) {
              dead++;

              addLater(Explosion()
                ..x = c.frame.topLeft.dx
                ..y = c.frame.topLeft.dy);
              addLater(Smoke(c.frame.topLeft.dx, c.frame.topLeft.dy));
              addLater(Shake(this.camera, intensity: 10));
            }
          }
        }

        score.increment(dead);

        if (player != null && player.health >= 0) {
          health.health = player.health;
        }

        if (_stop) {
          for (Component c in components) {
            if (c is Spawner) {
              c.stop = true;
            } else if (c is ParallaxComponent) {
              // c.baseSpeed = Offset(0, 0);
              // c.layerDelta = Offset(0, 0);
            }
          }
        }
      } else {
        for (Component c in components) {
          if (c is Health) {
            c.health = 0;
          }
        }
      }
    }
  }

  @override
  Color backgroundColor() {
    return Color(0xFF3a1439);
  }

  void startMove(Offset localPosition) {}

  void updateMove(Offset o) {
    player?.move(o.dx, o.dy);
  }

  void endMove() {
    player?.stop();
  }

  void _addStars() {
    addLater(ParallaxComponent([
      ParallaxImage("stars_far.png",
          repeat: ImageRepeat.repeatY, alignment: Alignment.center),
      ParallaxImage("stars_close.png",
          repeat: ImageRepeat.repeatY, alignment: Alignment.center)
    ])
      ..baseSpeed = Offset(0, -50)
      ..layerDelta = Offset(0, -50));
  }

  void _addClever() {
    if (components.where((e) => e is Clever).length <= 2) {
      addLater(Clever((a, b, c) {
        Bullet bullet = Bullet(b, up: false);
        double x1 = a.x + a.width * 0.5 - bullet.width * 0.5;
        double y1 = a.y + bullet.height;
        addLater(bullet
          ..x = x1
          ..y = y1);
        Flame.audio.play("laser_enemy.wav");
      }));
    }
  }

  void _addKamikaze() {
    if (components.where((e) => e is Kamikaze).length == 0) {
      addLater(Kamikaze());
    }
  }

  void _addPowerUp() {
    addLater(NumberHelper.random > 0.5 ? Laser() : Armour());
  }

  @override
  void onKeyEvent(RawKeyEvent event) {
    if (event.isKeyPressed(LogicalKeyboardKey.keyA) ||
        event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
      updateMove(Offset.zero);
    } else if (event.isKeyPressed(LogicalKeyboardKey.keyD) ||
        event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
      updateMove(Offset(_size.width, 0));
    } else {
      endMove();
    }
  }

  void _addPrimaryBulets(Ship a, String b) {
    Bullet first = Bullet(b);
    double x1 = a.x - first.width * 0.5;
    double y1 = a.y + first.height;
    addLater(first
      ..x = x1
      ..y = y1);

    Bullet second = Bullet(b);
    double x2 = a.x + a.width - second.width * 0.5;
    double y2 = a.y + second.height;
    addLater(second
      ..x = x2
      ..y = y2);

    addLater(Flare()
      ..x = x1
      ..y = y1);
    addLater(Flare()
      ..x = x2
      ..y = y2);
  }

  void _addSecondaryBulets(Ship a, String b) {
    Bullet first = Bullet(b);
    double x1 = a.x + first.width * 0.5;
    double y1 = a.y + first.height;
    addLater(first
      ..x = x1
      ..y = y1);

    Bullet second = Bullet(b);
    double x2 = a.x + a.width - second.width * 1.5;
    double y2 = a.y + second.height;
    addLater(second
      ..x = x2
      ..y = y2);

    addLater(Flare()
      ..x = x1
      ..y = y1);
    addLater(Flare()
      ..x = x2
      ..y = y2);
  }

  bool get isRunning => _start && !_stop;
  bool get isPaused => _pause;

  @override
  void onHorizontalDragDown(DragDownDetails details) {
    startMove(details.localPosition);
  }

  @override
  void onHorizontalDragStart(DragStartDetails details) {
    startMove(details.localPosition);
  }

  @override
  void onHorizontalDragCancel() {
    endMove();
  }

  @override
  void onHorizontalDragUpdate(DragUpdateDetails details) {
    updateMove(details.localPosition);
  }

  @override
  void onHorizontalDragEnd(DragEndDetails details) {
    endMove();
  }
}
