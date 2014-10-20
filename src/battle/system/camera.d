module battle.system.camera;

import dau.all;
import battle.battle;
import dau.graphics.camera;

class BattleCameraSystem : System!Battle {
  this(Battle b) {
    super(b);
  }

  override {
    void update(float time, InputManager input) {
      scene.camera.move(input.scrollDirection * cameraScrollSpeed);
    }

    void start() {
    }

    void stop() {
    }
  }
}
