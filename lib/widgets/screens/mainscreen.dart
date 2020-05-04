import 'package:flame/util.dart';
import 'package:flameblasterfaster/game/blasterfaster.dart';
import 'package:flameblasterfaster/widgets/button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainScreen extends StatefulWidget {
  final Util util;
  MainScreen(this.util, {Key key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState(util);
}

class _MainScreenState extends State<MainScreen> {
  BlasterFaster _game;
  Util _util;
  _MainScreenState(this._util);

  @override
  void initState() {
    super.initState();

    _game = BlasterFaster(() => setState(() => {}));

    _util.addGestureRecognizer(PanGestureRecognizer()
      ..onStart = _onDragStart
      ..onUpdate = _onDragUpdate
      ..onEnd = _onDragEnd
      ..onCancel = _onDragCancel);
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
      color: Color(0xFF3a1439),
      child: Center(
        child: SizedBox(
          child: ClipRect(child: _buildScreen()),
          width: 320,
          height: 600,
        ),
      ),
    );
  }

  Widget _buildScreen() {
    return _game.isRunning && !_game.isPaused
        ? _game.widget
        : Stack(
            children: <Widget>[
              _game.widget,
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

  void _onDragStart(DragStartDetails d) {
    _game?.startMove(d.localPosition);
  }

  void _onDragUpdate(DragUpdateDetails d) {
    _game?.updateMove(d.localPosition);
  }

  void _onDragEnd(DragEndDetails d) {
    _game?.endMove();
  }

  void _onDragCancel() {
    _onDragEnd(null);
  }
}
