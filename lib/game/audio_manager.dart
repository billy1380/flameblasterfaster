import "dart:io";

import "package:flame_audio/flame_audio.dart";
import "package:flutter/foundation.dart";
import "package:logging/logging.dart";

class AudioManager {
  static final Logger _log = Logger("AudioManager");
  static bool _muted = false;
  static AudioPlayer? _loop;
  static int _loopRequest = 0;
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
      // Each call supersedes earlier ones, including stopBackgroundLoop, so a
      // loop that finishes loading after it was stopped does not start playing.
      final int request = ++_loopRequest;

      final AudioPlayer? previous = _loop;
      _loop = null;
      await previous?.stop();
      await previous?.dispose();

      if (request != _loopRequest) return;

      final AudioPlayer loop = await FlameAudio.loopLongAudio(
        "music.${!kIsWeb && (Platform.isIOS || Platform.isMacOS) ? "mp3" : "ogg"}",
      );

      if (request != _loopRequest) {
        await loop.stop();
        await loop.dispose();
        return;
      }

      _loop = loop;
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
    _loopRequest++;

    final AudioPlayer? loop = _loop;
    _loop = null;
    loop?.stop();
    loop?.dispose();
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
