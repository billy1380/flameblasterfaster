import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flameblasterfaster/components/should_destory.dart';

typedef void Spawn();

class Spawner extends Component implements ShouldDestroy {
  final Spawn spawn;
  final double after;
  int? times;
  double _passed = 0;
  bool stop = false;

  Spawner(this.after, this.spawn, {this.times});

  @override
  void render(Canvas c) {}

  @override
  void update(double t) {
    if (!stop) {
      _passed += t;

      if (_passed > after) {
        _passed = 0;
        spawn();

        if (times != null) {
          times = times! - 1;
        }
      }
    }
  }

  @override
  bool get destroy {
    return times != null && times! >= 0;
  }
}
