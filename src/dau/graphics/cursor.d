module dau.graphics.cursor;

import dau.allegro;
import dau.engine;
import dau.geometry.vector;
import dau.graphics.sprite;

class CursorManager {
  this(Sprite[string] sprites) {
    _cursorSprites = sprites;
  }

  void setSprite(string key) {
    if (key is null) {
      al_show_mouse_cursor(mainDisplay);
      _currentSprite = null;
    }
    else {
      assert(key in _cursorSprites, "no cursor sprite named " ~ key ~ " was registered");
      al_hide_mouse_cursor(mainDisplay);
      _currentSprite = _cursorSprites[key];
    }
  }

  void update(float time) {
    if (_currentSprite !is null) {
      _currentSprite.update(time);
    }
  }

  void draw(Vector2i pos) {
    if (_currentSprite !is null) {
      _currentSprite.draw(pos);
    }
  }

  private:
  Sprite[string] _cursorSprites;
  Sprite _currentSprite;
}
