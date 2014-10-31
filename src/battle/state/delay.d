module battle.state.delay;

import dau.all;
import battle.battle;

private enum defaultWaitTime = 0.2f;

/// this state waits for a specified time before popping itself
class Delay : State!Battle {
  alias Action = void delegate(Battle);
  this(float time = defaultWaitTime, Action onEnd = null) {
    _timer = time;
    _onEnd = onEnd;
  }

  override { // TODO: show effect on status bar
    void update(Battle b, float time, InputManager input) {
      _timer -= time;
      if (_timer < 0) {
        if (_onEnd !is null) {
          _onEnd(b);
        }
        b.states.popState();
      }
    }
  }

  private:
  float _timer;
  Action _onEnd;
}
