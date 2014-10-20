module dau.scene;

import std.algorithm;
import dau.setup;
import dau.state;
import dau.input;
import dau.entity;
import dau.system;
import dau.gui.manager;
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
  this(State!T firstState, System!(T)[] systems) {
    _inputManager  = new InputManager;
    _entityManager = new EntityManager;
    _stateMachine  = new StateMachine!T;
    _spriteBatch   = new SpriteBatch;
    _guiManager    = new GUIManager;
    _camera        = new Camera(Settings.screenW, Settings.screenH);
    _systems       = systems;
    _stateMachine.pushState(firstState);
  }

  @property {
    auto entities() { return _entityManager; }
    auto states()   { return _stateMachine; }
    auto input()    { return _inputManager; }
    auto camera()   { return _camera; }
    auto gui()      { return _guiManager; }
  }

  override {
    void enter() { }
    void exit()  { }
    /// called every frame before drawing
    void update(float time) {
      _inputManager.update(time);
      _entityManager.updateEntities(time);
      _stateMachine.update(cast(T) this, time, _inputManager);
      _guiManager.update(time);
      foreach(sys ; _systems) {
        if (sys.active) {
          sys.update(time, input);
        }
      }
    }

    /// called every frame between screen clear and screen flip
    void draw() {
      _entityManager.drawEntities(_spriteBatch);
      _stateMachine.draw(cast(T) this, _spriteBatch);
      _spriteBatch.render(camera);
      _guiManager.draw(); // gui draws over state & entities
    }
  }

  S getSystem(S)() {
    auto res = _systems.map!(x => cast(S) x).find!(x => x !is null);
    assert(!res.empty, "failed to find system " ~ S.stringof ~ " in scene " ~ T.stringof);
    return res.front;
  }

  void enableSystem(S)() {
    getSystem!S().active = true;
  }

  void disableSystem(S)() {
    getSystem!S.active = false;
  }

  private:
  EntityManager  _entityManager;
  GUIManager     _guiManager;
  StateMachine!T _stateMachine;
  InputManager   _inputManager;
  SpriteBatch    _spriteBatch;
  Camera         _camera;
  System!(T)[]     _systems;

  private:
  bool _started;
}

interface IScene {
  void enter();
  void exit();
  void update(float time);
  void draw();
}
