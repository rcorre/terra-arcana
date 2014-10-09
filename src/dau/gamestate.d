module dau.gamestate;

import std.container : SList;

class GameState {
  /// called once immediately before the state's first update
  void start() { }
  /// called every frame before drawing
  void update(float time) { }
  /// called every frame between screen clear and screen flip
  void draw() { }
  /// called once when the state is removed
  void end() { }

  private:
  bool _started;
}

/// place a new state on the state stack
void pushState(GameState state) {
  _stateStack.insertFront(state);
}

/// remove the current state
void popState() {
  _stateStack.front.end();
  _stateStack.removeFront;
}

/// pop the current state (if there is a current state) and push a new state
void setState(GameState state) {
  if (!_stateStack.empty) {
    popState();
  }
  pushState(state);
}

package:
void updateState(float time) {
  if (!_stateStack.front._started) {
    _stateStack.front.start();
    _stateStack.front._started = true;
  }

  _stateStack.front.update(time);
}

void drawState() {
  _stateStack.front.draw();
}

private:
SList!GameState _stateStack;
