module battle.system.camera;

import dau.all;
import battle.battle;
import dau.graphics.camera;

private enum scrollSpeed = 700f;

class BattleCameraSystem : System!Battle {
  this(Battle b) {
    super(b);
  }

  override {
    void update(float time, InputManager input) {
      if (_autoScrollMode) {
        auto moved = scene.camera.move(_autoScrollVelocity * time);
        if (moved.len == 0) {
          _autoScrollMode = false;
        }
      }
      else { // move with input if not autoscrolling
        scene.camera.move(input.scrollDirection * scrollSpeed * time);
      }
    }

    void start() {
    }

    void stop() {
    }
  }

  void autoScrollTo(Vector2i destination, float speedFactor = 1f) {
    auto disp = cast(Vector2f) destination - scene.camera.bounds.center;
    _autoScrollVelocity = disp.normalized * scrollSpeed * speedFactor;
    _autoScrollMode = true;
  }

  private:
  Vector2f _autoScrollVelocity;
  bool _autoScrollMode;
}
