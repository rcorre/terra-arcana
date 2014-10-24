module battle.state.delay;

import dau.all;
import battle.battle;

private enum defaultWaitTime = 0.2f;

/// this state waits for a specified time before popping itself
class Delay : State!Battle {
  this(float time = defaultWaitTime) {
    _timer = time;
  }

  override { // TODO: show effect on status bar
    void update(Battle b, float time, InputManager input) {
      _timer -= time;
      if (_timer < 0) {
        b.states.popState();
      }
    }
  }

  private:
  float _timer;
}

