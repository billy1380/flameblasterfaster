import 'package:flame/animation.dart';
import 'package:flame/components/animation_component.dart';

class Health extends AnimationComponent {
  Health()
      : super(
            94,
            40,
            Animation.sequenced("armor.png", 5,
                textureHeight: 20, textureWidth: 235 * 0.2)) {
    animation.currentIndex = 0;
    animation.loop = false;
    x = 10;
    y = 20;
  }

  @override
  bool isHud() => true;

  @override
  int priority() => 100;

  set health(int value) {
    animation.currentIndex = value;
  }
}
