import 'package:flame/components.dart';
import 'package:flameblasterfaster/physics/collideable.dart';

class CollisionProcessor {
  static List<Hit> process(Iterable<Component> components) {
    List<Hit> hits = [];
    List<Component> list =
        components.where((e) => e is Collidable).toList(growable: false);

    for (int i = 0; i < list.length; i++) {
      Collidable c = list[i] as Collidable;

      for (int j = i + 1; j < list.length; j++) {
        Collidable d = list[j] as Collidable;

        if (c.intersects(d)) {
          d.hit(c);
          c.hit(d);

          hits.add(Hit(c, d));
        }
      }
    }

    return hits;
  }
}
