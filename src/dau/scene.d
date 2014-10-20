module dau.scene;

import dau.setup;
import dau.state;
import dau.input;
import dau.entity;
import dau.graphics.spritebatch;
import dau.graphics.camera;

private IScene _currentScene;

void setScene(T)(Scene!T newScene) {
  if (_currentScene !is null) {
    _currentScene.exit();
  }
  newScene.enter();
  _currentScene = newScene;
}

@property auto currentScene() { return _currentScene; }

class Scene(T) : IScene {
  this(State!T firstState) {
    _inputManager = new InputManager;
    _entityManager = new EntityManager;
    _stateMachine = new StateMachine!T;
    _spriteBatch = new SpriteBatch();
    _camera = new Camera(Settings.screenW, Settings.screenH);
    _stateMachine.pushState(firstState);
  }

  @property {
    auto entities() { return _entityManager; }
    auto states() { return _stateMachine; }
    auto input() { return _inputManager; }
    auto camera() { return _camera; }
  }

  override {
    void enter() { }
    void exit()  { }
    /// called every frame before drawing
    void update(float time) {
      _inputManager.update(time);
      _entityManager.updateEntities(time);
      _stateMachine.update(cast(T) this, time, _inputManager);
    }

    /// called every frame between screen clear and screen flip
    void draw() {
      _stateMachine.draw(cast(T) this, _spriteBatch);
      _entityManager.drawEntities(_spriteBatch);
      _spriteBatch.render(camera);
    }
  }

  private:
  EntityManager  _entityManager;
  StateMachine!T _stateMachine;
  InputManager   _inputManager;
  SpriteBatch    _spriteBatch;
  Camera         _camera;

static this() {
  onInit({});
}

  private:
  bool _started;
}

interface IScene {
  void enter();
  void exit();
  void update(float time);
  void draw();
}
