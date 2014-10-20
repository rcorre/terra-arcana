module dau.system;

import dau.input;

abstract class System(SceneType) {
  this(SceneType scene) {
    _scene = scene;
  }

  @property {
    bool active() { return _active; }
    void active(bool val) { 
      if (!active && val) {
        start();
      }
      else if (active && !val) {
        stop();
      }
      _active = val;
    }

    auto scene() { return _scene; }
  }

  void update(float time, InputManager input);
  void start();
  void stop();

  private bool _active;
  private SceneType _scene;
}
