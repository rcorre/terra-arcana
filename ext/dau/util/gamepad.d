module dau.util.gamepad;

import std.conv;
import std.typecons;
import dau.engine;
import dau.geometry.all;

enum Button360 {
  a           = 0,
  b           = 1,
  x           = 2,
  y           = 3,
  lb          = 4,
  rb          = 5,
  back        = 6,
  start       = 7,
  xbox        = 8,
  left_stick  = 9,
  right_stick = 10
}

class GamePad {
  private enum deadZone = 0.2;

  this(int id) {
    _joystick = al_get_joystick(id);
    _prevState = emptyState();
    _currentState = emptyState();
  }

  void update(float time) {
    if (_joystick) {
      _prevState = _currentState;
      al_get_joystick_state(_joystick, &_currentState);
    }
  }

  @property {
    bool connected() { return _joystick !is null; }

    Vector2f scrollDirection() {
      auto scroll = _currentState.leftStickPos;
      return (scroll.len < deadZone) ? Vector2f.Zero : scroll;
    }

    bool tappedDown() {
      return (_currentState.leftStickPos.y > deadZone) && (_prevState.leftStickPos.y < deadZone);
    }

    bool tappedUp() {
      return (_currentState.leftStickPos.y < -deadZone) && (_prevState.leftStickPos.y > -deadZone);
    }

    bool tappedLeft() {
      return (_currentState.leftStickPos.x < -deadZone) && (_prevState.leftStickPos.x > -deadZone);
    }

    bool tappedRight() {
      return (_currentState.leftStickPos.x > deadZone) && (_prevState.leftStickPos.x < deadZone);
    }
  }

  bool pressed(Button360 button) {
    return (_currentState.button[button] != 0) && (_prevState.button[button] == 0);
  }

  bool released(Button360 button) {
    return (_currentState.button[button] != 0) && (_prevState.button[button] == 0);
  }

  bool held(Button360 button) {
    return (_currentState.button[button] != 0);
  }

  private:
  ALLEGRO_JOYSTICK* _joystick;
  ALLEGRO_JOYSTICK_STATE _currentState, _prevState;
}

private:
@property Vector2f leftStickPos(ALLEGRO_JOYSTICK_STATE state) {
  auto stick = state.stick[0];
  return Vector2f(stick.axis[0], stick.axis[1]);
}

@property auto emptyState() {
  auto state = ALLEGRO_JOYSTICK_STATE();
  foreach(ref stick ; state.stick) {
    foreach(ref axis ; stick.axis) {
      axis = 0;
    }
  }
  return state;
}
