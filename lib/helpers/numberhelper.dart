import 'dart:math';

class NumberHelper {
  static final Random _r = Random.secure();

  static double get random {
    return _r.nextDouble();
  }
}
