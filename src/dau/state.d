module dau.state;

import std.stdio, std.path, std.conv, std.string;
import std.container : SList;
import dau.input;
import dau.graphics.spritebatch;

/// Generic behavioral state
class State(T) {
  /// called only once before the state is first updated
  void start(T object) { }
  /// called only once when the state is removed
  void end(T object) { }
  /// called once whenever the state becomes active (pushed to top or state above is popped)
  void enter(T object) { }
  /// called once whenever the state becomes inactive (popped or new state pushed above)
  void exit(T object) { }
  /// called every frame before drawing
  void update(T object, float time, InputManager input) { }
  /// called every frame between screen clear and screen flip
  void draw(T object, SpriteBatch sb) { }

  private bool _active, _started;
}

/// State stack for managing states
class StateMachine(T) {
  this(T obj) {
    _obj = obj;
  }

  @property {
    auto currentState() { return _stateStack.front; }
    bool empty() { return _stateStack.empty; }
  }

  /// place a new state on the state stack
  void pushState(State!T state) {
    _stateStack.insertFront(state);
    debug(StateTrace) { printStateTrace(); }
  }

  /// remove the current state
  void popState() {
    currentState.exit(_obj);
    currentState.end(_obj);
    _stateStack.removeFront;
    _prevState = null;
    debug(StateTrace) { printStateTrace(); }
  }

  /// pop the current state (if there is a current state) and push a new state
  void setState(State!T state) {
    if (!_stateStack.empty) {
      popState();
    }
    pushState(state);
  }

  void update(float time, InputManager input) {
    activateTop();
    currentState.update(_obj, time, input);
  }

  void draw(SpriteBatch sb) {
    activateTop();
    currentState.draw(_obj, sb);
  }

  void printStateTrace() {
    foreach(state ; _stateStack) {
      write(typeid(state).to!string.extension.chompPrefix("."), " | ");
    }
    writeln;
  }

  private:
  SList!(State!T) _stateStack;
  State!T _prevState;
  T _obj;

  void activateTop() {
    while (!currentState._active) { // call enter() is state is returning to activity
      currentState._active = true;
      if (_prevState !is null) {
        _prevState._active = false;
        _prevState.exit(_obj);
      }
      _prevState = currentState;
      if (!currentState._started) {
        currentState._started = true;
        currentState.start(_obj);
      }
      currentState.enter(_obj);
    }
  }
}
