import 'dart:io';

import 'package:flame/flame.dart';
import 'package:flameblasterfaster/widgets/screens/mainscreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:flame_audio/flame_audio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _setupLogging();

  if (kIsWeb) {
    FlameAudio.loopLongAudio("music.ogg");
    runApp(MainScreen());
  } else {
    await Flame.device.fullScreen();
    await Flame.device.setOrientation(DeviceOrientation.portraitUp);

    FlameAudio.audioCache.loadAll([
      "powerup.wav",
      "explosion.wav",
      "hit_enemy.wav",
      "hit_ship.wav",
      "laser_enemy.wav",
      "laser_ship.wav",
      if (Platform.isIOS || Platform.isMacOS) "music.mp3" else "music.ogg",
    ]).then((v) {
      if (Platform.isIOS || Platform.isMacOS) {
        FlameAudio.loopLongAudio("music.mp3");
      } else {
        FlameAudio.loopLongAudio("music.ogg");
      }
      runApp(MainScreen());
    });
  }
}

void _setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print("${record.level.name}: ${record.time}: ${record.message}");
  });
}
