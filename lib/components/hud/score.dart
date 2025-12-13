import "package:flame/components.dart";
import "package:flame/flame.dart";
import "package:flameblasterfaster/components/fonts.dart";

class Score extends Component {
  int _score = 0;
  late TextComponent _tc;
  late SpriteComponent _bc;

  Score() {
    _tc = TextComponent(
      text: 0.toString().padLeft(6, "0"),
      priority: 100,
      textRenderer: Fonts.display,
    );
    _bc = SpriteComponent(
      sprite: Sprite(Flame.images.fromCache("score.png")),
      scale: Vector2.all(2),
    );

    add(_bc);
    add(_tc);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    x = size.x - (_bc.width * _bc.scale.x) + 10;
    y = 10;
  }

  void increment(int by) {
    _score += by;

    _tc.text = _score.toString().padLeft(6, "0");
  }

  set x(double value) {
    _tc.x = value - 10;
    _bc.x = value - 22;
  }

  set y(double value) {
    _tc.y = value + 8;
    _bc.y = value + 8;
  }
}
