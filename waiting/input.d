module dau.util.input;

import std.algorithm : max, min, any;
import dau.engine;
import dau.geometry.vector;
import dau.util.gamepad;

enum MouseKeymap {
  lmb = 1,
  rmb = 2
}

enum Keymap {
  left  = [ALLEGRO_KEY_A],
  right = [ALLEGRO_KEY_D],
  up    = [ALLEGRO_KEY_W],
  down  = [ALLEGRO_KEY_S],

  confirm = [ALLEGRO_KEY_J],
  cancel  = [ALLEGRO_KEY_K],
  end     = [ALLEGRO_KEY_SPACE],
  faster  = [ALLEGRO_KEY_LSHIFT],
  start = [ALLEGRO_KEY_ENTER],

  next = [ALLEGRO_KEY_E],
  previous = [ALLEGRO_KEY_Q],

  inspect = [ALLEGRO_KEY_F],
}

private enum {
  scrollSpeed = 14
}

class InputManager {
  this() {
    _gamePad = new GamePad(0);
    update(0);
  }

  void reconfigureGamepad() {
    al_reconfigure_joysticks();
    _gamePad = new GamePad(0);
  }

  void update(float time) {
    _gamePad.update(time);
    _prevKeyboardState = _curKeyboardState;
    _prevMouseState = _curMouseState;
    al_get_keyboard_state(&_curKeyboardState);
    al_get_mouse_state(&_curMouseState);
  }

  @property {
    bool gamepadConnected() { return _gamePad.connected; }

    Vector2f scrollDirection() {
      Vector2f scroll = Vector2f.zero;
      if (keyHeld(Keymap.up)) {
        scroll.y = -1;
      }
      else if (keyHeld(Keymap.down)) {
        scroll.y = 1;
      }
      if (keyHeld(Keymap.left)) {
        scroll.x = -1;
      }
      else if (keyHeld(Keymap.right)) {
        scroll.x = 1;
      }
      return scroll == Vector2f.zero ? _gamePad.scrollDirection : scroll;
    }

    bool selectUp()    { return keyPressed(Keymap.up)    || _gamePad.tappedUp; }
    bool selectDown()  { return keyPressed(Keymap.down)  || _gamePad.tappedDown; }
    bool selectLeft()  { return keyPressed(Keymap.left)  || _gamePad.tappedLeft; }
    bool selectRight() { return keyPressed(Keymap.right) || _gamePad.tappedRight; }

    bool confirm() { return keyPressed(Keymap.confirm)   || _gamePad.pressed(Button360.a); }
    bool cancel()  { return keyPressed(Keymap.cancel)    || _gamePad.pressed(Button360.b); }
    bool endTurn() { return keyPressed(Keymap.end)       || _gamePad.pressed(Button360.back); }
    bool inspect() { return keyPressed(Keymap.inspect)   || _gamePad.pressed(Button360.y); }

    bool next() { return keyPressed(Keymap.next) || _gamePad.pressed(Button360.rb); }
    bool previous() { return keyPressed(Keymap.previous) || _gamePad.pressed(Button360.lb); }

    bool speedScroll() { return keyHeld(Keymap.faster) || _gamePad.held(Button360.x); }

    bool start() { return keyPressed(Keymap.start) || _gamePad.pressed(Button360.start); }
  }

  Vector2i mousePos() {
    return Vector2i(_curMouseState.x, _curMouseState.y);
  }

  private:
  bool keyHeld(Keymap buttons) {
    return buttons.any!(key => al_key_down(&_curKeyboardState, key));
  }

  bool keyPressed(Keymap buttons) {
    return buttons.any!(key => !al_key_down(&_prevKeyboardState, key) && al_key_down(&_curKeyboardState, key));
  }

  bool keyReleased(int keycode) {
    return al_key_down(&_prevKeyboardState, keycode) && !al_key_down(&_curKeyboardState, keycode);
  }

  bool mouseClicked(MouseKeymap button) {
    int b = cast(int) button;
    return !al_mouse_button_down(&_prevMouseState, b) && al_mouse_button_down(&_curMouseState, b);
  }

  Vector2f _scrollAccumulator = Vector2f.zero;

  ALLEGRO_KEYBOARD_STATE _curKeyboardState, _prevKeyboardState;
  ALLEGRO_MOUSE_STATE _curMouseState, _prevMouseState;

  GamePad _gamePad;
}
