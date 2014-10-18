module dau.fsm;

import std.container : SList;

/// Generic behavioral state
class State(T) {
  /// called once whenever the state becomes active (pushed to top or state above is popped)
  void enter(T object) { }
  /// called once whenever the state becomes inactive (popped or new state pushed above)
  void exit(T object) { }
  /// called every frame before drawing
  void update(T object, float time) { }
  /// called every frame between screen clear and screen flip
  void draw(T object, SpriteBatch sb) { }

  private bool _active;
}

/// State stack for managing states
class StateStack(T) {
  @property auto currentState() { return _stateStack.front; }

  /// place a new state on the state stack
  void pushState(State!T state) {
    _stateStack.insertFront(state);
  }

  /// remove the current state
  void popState() {
    currentState.exit();
    currentState._active = false;
    _stateStack.removeFront;
  }

  /// pop the current state (if there is a current state) and push a new state
  void setState(State!T state) {
    if (!_stateStack.empty) {
      popState();
    }
    pushState(state);
  }

  void update(T object, float time) {
    if (!currentState._active) { // call enter() is state is returning to activity
      currentState.enter();
      currentState._active = true;
    }
    currentState.update();
  }

  void draw(T object, SpriteBatch sb) {
    currentState.draw();
  }

  private:
  SList!(State!T) _stateStack;
}
