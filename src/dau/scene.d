module dau.scene;

import std.container : SList;
import dau.graphics.spritebatch;

class Scene {
  /// called once before first update and after previous scene exits
  void enter() { }
  /// called every frame before drawing
  void update(float time) { }
  /// called every frame between screen clear and screen flip
  void draw(SpriteBatch sb) { }
  /// called once when the scene is replaced by another or the game exits
  void exit() { }
}

@property {
  Scene currentScene() {
    return _currentScene;
  }

  void currentScene(Scene newScene) {
    if (_currentScene !is null) {
      _currentScene.exit();
    }
    newScene.enter();
    _currentScene = newScene;
  }
}

private:
Scene _currentScene;
