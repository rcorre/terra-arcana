module dau.state;

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

  @property auto currentState() { return _stateStack.front; }

  /// place a new state on the state stack
  void pushState(State!T state) {
    printStateTrace();
    _stateStack.insertFront(state);
  }

  /// remove the current state
  void popState() {
    printStateTrace();
    currentState.end(_obj);
    _stateStack.removeFront;
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

  private:
  SList!(State!T) _stateStack;
  State!T _prevState;
  T _obj;

  void activateTop() {
    if (!currentState._active) { // call enter() is state is returning to activity
      if (_prevState !is null) {
        _prevState.exit(_obj);
        _prevState._active = false;
      }
      if (!currentState._started) {
        currentState.start(_obj);
        currentState._started = true;
      }
      currentState.enter(_obj);
      currentState._active = true;
      _prevState = currentState;
    }
  }

  void printStateTrace() {
    debug(StateTrace) {
      import std.stdio, std.path, std.conv, std.string;
      foreach(state ; _stateStack) {
        write(typeid(state).to!string.extension.chompPrefix("."), " | ");
      }
      writeln;
    }
  }
}
