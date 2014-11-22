module dau.gui.textinput;

import std.conv, std.string, std.range;
import dau.input;
import dau.allegro;
import dau.engine;
import dau.gui.element;
import dau.gui.data;
import dau.gui.textbox;
import dau.geometry.all;
import dau.graphics.all;

class TextInput : GUIElement {
  this(GUIData data) {
    auto pos = data.get("offset", "0,0").parseVector!int;
    auto anchor = data.get("anchor", "topLeft").to!Anchor;
    super(data, pos, anchor);

    _textBox = new TextBox(data.child["text"]);
    addChild(_textBox);

    _charLimit = ("charLimit" in data) ? data["charLimit"].to!int : int.max;

    _focusedTint = data.get("focusedTint", "1, 1, 1").parseColor;
    _unfocusedTint = data.get("unfocusedTint", "0.5, 0.5, 0.5").parseColor;
    sprite.tint = _unfocusedTint;

    if ("cursorTexture" in data && "cursorAnimation" in data) {
      _cursor = new Animation(data["cursorTexture"], data["cursorAnimation"], Animation.Repeat.loop);
    }

    registerEventHandler(&handleKeyChar, ALLEGRO_EVENT_KEY_CHAR);
  }

  @property {
    string text() { return _textBox.text; }
    void text(string val) {
      _textBox.text = val.take(_charLimit).to!string;
    }
  }

  override {
    void update(float time) {
      super.update(time);
      if (hasFocus && _cursor !is null) { _cursor.update(time); }
    }

    void draw(Vector2i parentTopLeft) {
      super.draw(parentTopLeft);
      if (hasFocus && _cursor !is null) {
        auto offset = parentTopLeft + area.topLeft + Vector2i(0, _textBox.height / 2);
        _cursor.draw(offset + _textBox.textArea.topRight);
      }
    }

    void onFocus(bool focus) {
      sprite.tint = focus ? _focusedTint : _unfocusedTint;
    }
  }

  private:
  TextBox _textBox;
  int _charLimit;
  Color _focusedTint, _unfocusedTint;
  Animation _cursor;

  void handleKeyChar(ALLEGRO_EVENT event) {
    if (!hasFocus) { return; }
    if (event.keyboard.keycode == ALLEGRO_KEY_BACKSPACE) {
      text = text.chop;
    }
    else {
      text = text ~ cast(char) event.keyboard.unichar;
    }
  }
}

