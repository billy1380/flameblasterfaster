import 'package:flame/flame.dart';
import 'package:flameblasterfaster/widgets/screens/mainscreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _setupLogging();

  if (kIsWeb) {
    Flame.audio.loopLongAudio("music.ogg");
    runApp(MainScreen());
  } else {
    await Flame.util.fullScreen();
    await Flame.util.setOrientation(DeviceOrientation.portraitUp);

    Flame.audio.disableLog();
    Flame.audio.loadAll([
      "powerup.wav",
      "explosion.wav",
      "hit_enemy.wav",
      "hit_ship.wav",
      "laser_enemy.wav",
      "laser_ship.wav",
      "music.ogg",
    ]).then((v) {
      Flame.audio.loopLongAudio("music.ogg");
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
