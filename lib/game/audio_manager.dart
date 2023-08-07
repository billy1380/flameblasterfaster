import 'dart:io';

import 'package:flame_audio/flame_audio.dart';
import 'package:logging/logging.dart';

class AudioManager {
  static final Logger _log = Logger("AudioManager");
  static bool _muted = false;

  static void mute() {
    _muted = true;
  }

  static void unmute() {
    _muted = false;
  }

  static void playBackgroundLoop() {
    if (_muted) {
      _log.info("Not playing background music because muted is $_muted");
    } else {
      if (Platform.isIOS || Platform.isMacOS) {
        FlameAudio.loopLongAudio("music.mp3");
      } else {
        FlameAudio.loopLongAudio("music.ogg");
      }
    }
  }

  static void play(String name) {
    if (_muted) {
      _log.info("Not playing $name because muted is $_muted");
    } else {
      FlameAudio.play(name);
    }
  }

  static void load() {
    FlameAudio.audioCache.loadAll([
      "powerup.wav",
      "explosion.wav",
      "hit_enemy.wav",
      "hit_ship.wav",
      "laser_enemy.wav",
      "laser_ship.wav",
      if (Platform.isIOS || Platform.isMacOS) "music.mp3" else "music.ogg",
    ]).then((v) {
      playBackgroundLoop();
    });
  }
}
