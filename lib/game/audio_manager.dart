import 'dart:io';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class AudioManager {
  static final Logger _log = Logger("AudioManager");
  static bool _muted = false;
  static AudioPlayer? _loop;

  static void mute() {
    _muted = true;
    _loop?.pause();
  }

  static void unmute() {
    _muted = false;
    _loop?.resume();
  }

  static Future<void> playBackgroundLoop() async {
    if (_muted) {
      _log.info("Not playing background music because muted is $_muted");
    } else {
      await _loop?.stop();
      await _loop?.dispose();

      _loop = await FlameAudio.loopLongAudio(
        "music.${!kIsWeb && (Platform.isIOS || Platform.isMacOS) ? "mp3" : "ogg"}",
      );
    }
  }

  static void play(String name) {
    if (_muted) {
      _log.info("Not playing $name because muted is $_muted");
    } else {
      FlameAudio.play(name);
    }
  }

  static void stopBackgroundLoop() {
    _loop?.stop();
  }

  static void load() {
    FlameAudio.audioCache
        .loadAll([
          "powerup.wav",
          "explosion.wav",
          "hit_enemy.wav",
          "hit_ship.wav",
          "laser_enemy.wav",
          "laser_ship.wav",
          if (!kIsWeb && (Platform.isIOS || Platform.isMacOS))
            "music.mp3"
          else
            "music.ogg",
        ])
        .then((v) {
          playBackgroundLoop();
        });
  }
}
