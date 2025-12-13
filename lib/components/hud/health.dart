import 'package:flame/components.dart';
import 'package:flame/flame.dart';

class Health extends SpriteAnimationComponent {
  Health()
    : super(
        animation: SpriteAnimation.fromFrameData(
          Flame.images.fromCache("armor.png"),
          SpriteAnimationData.sequenced(
            loop: false,
            amount: 5,
            amountPerRow: 5,
            stepTime: 1,
            textureSize: Vector2(235 * .2, 20),
          ),
        ),
        scale: Vector2.all(2),
        size: Vector2(235 * .2, 20),
        priority: 100,
        position: Vector2(10, 20),
      );

  set health(int value) {
    animationTicker?.currentIndex = value;
  }
}
