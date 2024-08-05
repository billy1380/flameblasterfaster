import 'package:flame/game.dart';
import 'package:flameblasterfaster/game/blasterfaster.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

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
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: BlasterFaster.width,
            maxHeight: BlasterFaster.height,
          ),
          child: ClipRect(child: _buildScreen()),
        ),
      ),
    );
  }

  Widget _buildScreen() => GameWidget(
        game: BlasterFaster(
          canQuit: !kIsWeb,
        ),
      );
}
