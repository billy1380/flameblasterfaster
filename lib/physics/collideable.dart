import "package:flutter/material.dart";

abstract class Collidable {
  Rect get frame;
  bool intersects(Collidable c);
  void hit(Collidable c);
}

class Hit {
  Collidable a, b;
  Hit(this.a, this.b);
}
