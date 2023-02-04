import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
import 'package:flame_audio/flame_audio.dart';
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
import 'package:flameblasterfaster/components/should_destory.dart';
import 'package:flameblasterfaster/components/smoke.dart';
import 'package:flameblasterfaster/components/spawner.dart';
import 'package:flameblasterfaster/helpers/numberhelper.dart';
import 'package:flameblasterfaster/physics/collideable.dart';
import 'package:flameblasterfaster/physics/collisionprocessor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BlasterFaster extends FlameGame
    with KeyboardEvents, HorizontalDragDetector {
  // static final Logger _log = Logger("BlasterFaster");

  Player? player;
  bool _stop = false;
  bool _pause = false;
  bool _start = false;

  final VoidCallback finished;

  Vector2 _size =
      Vector2(window.physicalSize.width, window.physicalSize.height);

  BlasterFaster(this.finished) {}

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await load("flare.png");
    await load("armor.png");
    await load("score.png");
    await load("powerup_armor.png");
    await load("powerup_laser.png");
    await load("stars_far.png");
    await load("stars_close.png");
    await load("ship.png");
    await load("laser_ship.png");
    await load("enemy_clever.png");
    await load("enemy_kamikaze.png");
    await load("laser_enemy.png");
    await load("explosion.png");
    await load("smoke.png");

    _addStars();
  }

  FutureOr<void> load(String fileName) => images.load(
        fileName,
        key: fileName,
      );

  void start() {
    children.where((e) => !(e is ParallaxComponent)).forEach((e) => remove(e));

    _addPlayer();

    add(Spawner(1, _addClever));
    add(Spawner(2, _addKamikaze));
    add(Spawner(10, _addPowerUp));

    add(Score());
    add(Health());

    _start = true;
    _stop = false;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    _size = size;
  }

  void _addPlayer() {
    add(player = Player((a, b, c) {
      _addPrimaryBulets(a, b);

      if (c > 0) {
        _addSecondaryBulets(a, b);
      }

      FlameAudio.play("laser_ship.wav");
    }));
  }

  @override
  void update(double t) {
    super.update(t);

    if (_start) {
      if (!_stop) {
        List<Hit> hits = CollisionProcessor.process(this.children);

        for (Hit h in hits) {
          if ((h.a is Player &&
                  (h.b is Enemy ||
                      (h.b is Bullet && (h.b as Bullet).isEnemy))) ||
              (h.b is Player &&
                  (h.a is Enemy ||
                      (h.a is Bullet && (h.a as Bullet).isEnemy)))) {
            add(Shake(camera, duration: 3, intensity: 100));
            add(Bleed(camera, 1));
          }

          if ((h.a is Player && h.b is Bullet && (h.b as Bullet).isEnemy) ||
              (h.a is Enemy && h.b is Bullet && (h.b as Bullet).isPlayer) ||
              (h.b is Player && h.a is Bullet && (h.a as Bullet).isEnemy) ||
              (h.b is Enemy && h.a is Bullet && (h.a as Bullet).isPlayer)) {
            add(Flare()
              ..x = h.a.frame.topLeft.dx
              ..y = h.a.frame.topLeft.dy);
          }
        }

        late Score score;
        late Player player;
        late Health health;

        int dead = 0;
        for (Component c in children) {
          if (c is Player) {
            player = c;
            if (!_stop) {
              _stop = c.isDead;

              if (_stop) {
                finished();
              }
            }

            if (c.isDead) {
              add(Explosion()
                ..x = c.frame.topLeft.dx
                ..y = c.frame.topLeft.dy);

              add(Smoke(c.frame.topLeft.dx, c.frame.topLeft.dy));
            }
          } else if (c is Score) {
            score = c;
          } else if (c is Health) {
            health = c;
          } else if (c is Enemy) {
            if (c.isDead) {
              dead++;

              add(Explosion()
                ..x = c.frame.topLeft.dx
                ..y = c.frame.topLeft.dy);
              add(Smoke(c.frame.topLeft.dx, c.frame.topLeft.dy));
              add(Shake(this.camera, intensity: 10));
            }
          }
        }

        score.increment(dead);

        if (player.health >= 0) {
          health.health = player.health;
        }

        if (_stop) {
          for (Component c in children) {
            if (c is Spawner) {
              c.stop = true;
            } else if (c is ParallaxComponent) {
              // c.baseSpeed = Offset(0, 0);
              // c.layerDelta = Offset(0, 0);
            }
          }
        }
      } else {
        for (Component c in children) {
          if (c is Health) {
            c.health = 0;
          }
        }
      }
    }

    for (ShouldDestroy c in children.whereType<ShouldDestroy>()) {
      if (c.destroy) {
        remove(c as Component);
      }
    }
  }

  @override
  Color backgroundColor() {
    return Color(0xFF3a1439);
  }

  void startMove(Vector2 localPosition) {}

  void updateMove(Vector2 o) {
    player?.move(o.x, o.y);
  }

  void endMove() {
    player?.stop();
  }

  void _addStars() {
    add(ParallaxComponent(
      parallax: Parallax(
        [
          ParallaxLayer(
            ParallaxImage(Flame.images.fromCache("stars_far.png"),
                repeat: ImageRepeat.repeatY, alignment: Alignment.center),
            velocityMultiplier: Vector2(0, -5),
          ),
          ParallaxLayer(
            ParallaxImage(Flame.images.fromCache("stars_close.png"),
                repeat: ImageRepeat.repeatY, alignment: Alignment.center),
            velocityMultiplier: Vector2(0, -15),
          )
        ],
        baseVelocity: Vector2(0, 5),
      ),
    ));
  }

  void _addClever() {
    if (children.where((e) => e is Clever).length <= 2) {
      add(Clever((a, b, c) {
        Bullet bullet = Bullet(b, up: false);
        double x1 = a.x + a.width * 0.5 - bullet.width * 0.5;
        double y1 = a.y + bullet.height;
        add(bullet
          ..x = x1
          ..y = y1);
        FlameAudio.play("laser_enemy.wav");
      }));
    }
  }

  void _addKamikaze() {
    if (children.where((e) => e is Kamikaze).length == 0) {
      add(Kamikaze());
    }
  }

  void _addPowerUp() {
    add(NumberHelper.random > 0.5 ? Laser() : Armour());
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event.isKeyPressed(LogicalKeyboardKey.keyA) ||
        event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
      updateMove(Vector2.zero());
    } else if (event.isKeyPressed(LogicalKeyboardKey.keyD) ||
        event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
      updateMove(Vector2(_size.x, 0));
    } else {
      endMove();
    }

    return KeyEventResult.handled;
  }

  void _addPrimaryBulets(Ship a, String b) {
    Bullet first = Bullet(b);
    double x1 = a.x - first.width * 0.5;
    double y1 = a.y + first.height;
    add(first
      ..x = x1
      ..y = y1);

    Bullet second = Bullet(b);
    double x2 = a.x + a.width - second.width * 0.5;
    double y2 = a.y + second.height;
    add(second
      ..x = x2
      ..y = y2);

    add(Flare()
      ..x = x1
      ..y = y1);
    add(Flare()
      ..x = x2
      ..y = y2);
  }

  void _addSecondaryBulets(Ship a, String b) {
    Bullet first = Bullet(b);
    double x1 = a.x + first.width * 0.5;
    double y1 = a.y + first.height;
    add(first
      ..x = x1
      ..y = y1);

    Bullet second = Bullet(b);
    double x2 = a.x + a.width - second.width * 1.5;
    double y2 = a.y + second.height;
    add(second
      ..x = x2
      ..y = y2);

    add(Flare()
      ..x = x1
      ..y = y1);
    add(Flare()
      ..x = x2
      ..y = y2);
  }

  bool get isRunning => _start && !_stop;
  bool get isPaused => _pause;

  @override
  void onHorizontalDragDown(DragDownInfo details) {
    startMove(details.eventPosition.game);
  }

  @override
  void onHorizontalDragStart(DragStartInfo details) {
    startMove(details.eventPosition.game);
  }

  @override
  void onHorizontalDragCancel() {
    endMove();
  }

  @override
  void onHorizontalDragUpdate(DragUpdateInfo details) {
    updateMove(details.eventPosition.game);
  }

  @override
  void onHorizontalDragEnd(DragEndInfo details) {
    endMove();
  }
}
