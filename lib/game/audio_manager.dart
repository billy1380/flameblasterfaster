import "dart:io";

import "package:flame_audio/flame_audio.dart";
import "package:flutter/foundation.dart";
import "package:logging/logging.dart";

class AudioManager {
  static final Logger _log = Logger("AudioManager");
  static bool _muted = false;
  static AudioPlayer? _loop;
  static final Map<String, AudioPool> _pools = {};

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
      if (_pools.containsKey(name)) {
        _pools[name]!.start();
      } else {
        FlameAudio.play(name);
      }
    }
  }

  static void stopBackgroundLoop() {
    _loop?.stop();
  }

  static Future<void> load() async {
    List<String> poolFiles = [
      "powerup.wav",
      "explosion.wav",
      "hit_enemy.wav",
      "hit_ship.wav",
      "laser_enemy.wav",
      "laser_ship.wav",
    ];

    for (String file in poolFiles) {
      _pools[file] = await FlameAudio.createPool(
        file,
        maxPlayers: 4,
        minPlayers: 1,
      );
    }

    FlameAudio.audioCache.loadAll([
      if (!kIsWeb && (Platform.isIOS || Platform.isMacOS))
        "music.mp3"
      else
        "music.ogg",
    ]);
  }
}
