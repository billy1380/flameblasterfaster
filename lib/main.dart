import 'package:flameblasterfaster/widgets/screens/mainscreen.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _setupLogging();

  runApp(const MainScreen());
}

void _setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint("${record.level.name}: ${record.time}: ${record.message}\n");
  });
}
