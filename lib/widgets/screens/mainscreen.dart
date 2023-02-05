import 'package:flame/game.dart';
import 'package:flameblasterfaster/game/blasterfaster.dart';
import 'package:flameblasterfaster/widgets/button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final BlasterFaster _game;
  late final GameWidget _gameWidget;

  _MainScreenState();

  @override
  void initState() {
    super.initState();

    _game = BlasterFaster(() => setState(() {}));
    _gameWidget = GameWidget(
      game: _game,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return Scaffold(body: kIsWeb ? _buildWebScreen() : _buildScreen());
      },
    );
  }

  Widget _buildWebScreen() {
    return Container(
      color: const Color(0xFF3a1439),
      child: Center(
        child: SizedBox(
          width: 320,
          height: 600,
          child: ClipRect(child: _buildScreen()),
        ),
      ),
    );
  }

  Widget _buildScreen() {
    return _game.isRunning && !_game.paused
        ? _gameWidget
        : Stack(
            children: <Widget>[
              _gameWidget,
              Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildButtons(),
              ))
            ],
          );
  }

  List<Widget> _buildButtons() {
    List<Widget> buttons = [
      Button("Start", "assets/images/button_normal.png",
          hover: "assets/images/button_hover.png",
          pressed: "assets/images/button_pressed.png",
          onPressed: () => setState(() => _game.start())),
    ];

    if (!kIsWeb) {
      buttons.add(
        Button("Quit", "assets/images/button_normal.png",
            hover: "assets/images/button_hover.png",
            pressed: "assets/images/button_pressed.png",
            onPressed: () => SystemNavigator.pop()),
      );
    }
    return buttons;
  }
}
