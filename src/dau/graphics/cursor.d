module dau.graphics.cursor;

import dau.allegro;
import dau.engine;
import dau.input;
import dau.graphics.sprite;

class CursorManager {
  this(Sprite[string] sprites) {
    _cursorSprites = sprites;
  }

  void setSprite(string key) {
    if (key is null) {
      al_show_mouse_cursor(mainDisplay);
    }
    else {
      assert(key in _cursorSprites, "no cursor sprite named " ~ key ~ " was registered");
      al_hide_mouse_cursor(mainDisplay);
      _currentSprite = _cursorSprites[key];
    }
  }

  void update(float time) {
    _currentSprite.update(time);
  }

  void draw(InputManager input) {
    _currentSprite.draw(input.mousePos);
  }

  private:
  Sprite[string] _cursorSprites;
  Sprite _currentSprite;
}
