import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/image_composition.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
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
import 'package:flameblasterfaster/components/text_button_component.dart';
import 'package:flameblasterfaster/game/audio_manager.dart';
import 'package:flameblasterfaster/helpers/numberhelper.dart';
import 'package:flameblasterfaster/physics/collideable.dart';
import 'package:flameblasterfaster/physics/collisionprocessor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BlasterFaster extends FlameGame
    with HasKeyboardHandlerComponents, HorizontalDragDetector {
  Player? player;
  TextButtonComponent? _startButton;
  TextButtonComponent? _quitButton;
  bool _stop = false;
  bool _start = false;
  static const double width = 400;
  static const double height = 800;
  static Vector2 max = Vector2(width, height);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // AudioManager.mute();

    if (kIsWeb) {
      AudioManager.playBackgroundLoop();
    } else {
      await Flame.device.fullScreen();
      await Flame.device.setOrientation(DeviceOrientation.portraitUp);

      AudioManager.load();
    }

    await _loadAssets();

    _addStars();

    _addButtons();
  }

  Future<void> _loadAssets() async {
    await loadImage("flare.png");
    await loadImage("armor.png");
    await loadImage("score.png");
    await loadImage("powerup_armor.png");
    await loadImage("powerup_laser.png");
    await loadImage("stars_far.png");
    await loadImage("stars_close.png");
    await loadImage("ship.png");
    await loadImage("laser_ship.png");
    await loadImage("enemy_clever.png");
    await loadImage("enemy_kamikaze.png");
    await loadImage("laser_enemy.png");
    await loadImage("explosion.png");
    await loadImage("smoke.png");
    await loadImage("button_normal.png");
    await loadImage("button_hover.png");
    await loadImage("button_pressed.png");
  }

  FutureOr<void> loadImage(String fileName) => images.load(
        fileName,
        key: fileName,
      );

  void start() {
    children.where((e) => e is! ParallaxComponent).forEach((e) => remove(e));

    _addPlayer();

    add(Spawner(1, _addClever));
    add(Spawner(2, _addKamikaze));
    add(Spawner(10, _addPowerUp));

    add(Score());
    add(Health());

    _start = true;
    _stop = false;
  }

  void finished() {
    if (_startButton != null) {
      add(_startButton!);
    }

    if (_quitButton != null) {
      add(_quitButton!);
    }
  }

  void _addPlayer() {
    add(player = Player(
      (ship, weapon, elevated) {
        _addPrimaryBulets(ship, weapon);

        if (elevated > 0) {
          _addSecondaryBulets(ship, weapon);
        }

        AudioManager.play("laser_ship.wav");
      },
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_start) {
      if (!_stop) {
        List<Hit> hits = CollisionProcessor.process(children);

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
          } else if (c is Enemy) {
            if (c.isDead) {
              dead++;

              add(Explosion()
                ..x = c.frame.topLeft.dx
                ..y = c.frame.topLeft.dy);
              add(Smoke(c.frame.topLeft.dx, c.frame.topLeft.dy));
              add(Shake(camera, intensity: 10));
            }
          }
        }

        for (Component c in children) {
          if (c is Score) {
            score = c;
          } else if (c is Health) {
            health = c;
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
    return const Color(0xFF3a1439);
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

  void _addButtons() {
    add(_startButton = TextButtonComponent(
      label: "Start",
      onPressed: () => start(),
    ));

    if (!kIsWeb) {
      add(_quitButton = TextButtonComponent(
        label: "Quit",
        onPressed: () => SystemNavigator.pop(),
      ));
    }
  }

  void _addClever() {
    if (children.whereType<Clever>().length <= 2) {
      add(Clever(
        (a, b, c) {
          Bullet bullet = Bullet(b, up: false);
          double x1 = a.x + a.width * 0.5 - bullet.width * 0.5;
          double y1 = a.y + bullet.height;
          add(bullet
            ..x = x1
            ..y = y1);
          AudioManager.play("laser_enemy.wav");
        },
      ));
    }
  }

  void _addKamikaze() {
    if (children.whereType<Kamikaze>().isEmpty) {
      add(Kamikaze());
    }
  }

  void _addPowerUp() {
    add(NumberHelper.random > 0.5 ? Laser() : Armour());
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    super.onKeyEvent(event, keysPressed);

    if (keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      updateMove(Vector2.zero());
    } else if (keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      updateMove(Vector2(canvasSize.x, 0));
    } else if (keysPressed.contains(LogicalKeyboardKey.space)) {
      paused = !paused;
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

  @override
  void onHorizontalDragDown(DragDownInfo info) {
    startMove(info.eventPosition.widget);
  }

  @override
  void onHorizontalDragStart(DragStartInfo info) {
    startMove(info.eventPosition.widget);
  }

  @override
  void onHorizontalDragCancel() {
    endMove();
  }

  @override
  void onHorizontalDragUpdate(DragUpdateInfo info) {
    updateMove(info.eventPosition.widget);
  }

  @override
  void onHorizontalDragEnd(DragEndInfo info) {
    endMove();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    _startButton?.position.setValues(
      camera.viewport.size.x * 0.5,
      camera.viewport.size.y * 0.5 - (kIsWeb ? 0 : 20),
    );

    _quitButton?.position.setValues(
      camera.viewport.size.x * 0.5,
      camera.viewport.size.y * 0.5 + 20,
    );
  }
}
