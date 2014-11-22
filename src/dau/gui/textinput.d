module dau.gui.textinput;

import std.conv, std.string, std.range;
import dau.input;
import dau.allegro;
import dau.engine;
import dau.gui.element;
import dau.gui.data;
import dau.gui.textbox;
import dau.geometry.all;
import dau.graphics.color;
import dau.graphics.font;

class TextInput : GUIElement {
  this(GUIData data) {
    auto pos = data.get("offset", "0,0").parseVector!int;
    auto anchor = data.get("anchor", "topLeft").to!Anchor;
    super(data, pos, anchor);

    _textBox = new TextBox(data.child["text"]);
    addChild(_textBox);

    _charLimit = ("charLimit" in data) ? data["charLimit"].to!int : int.max;

    registerEventHandler(&handleKeyChar, ALLEGRO_EVENT_KEY_CHAR);
  }

  @property {
    string text() { return _textBox.text; }
    void text(string val) {
      _textBox.text = val.take(_charLimit).to!string;
    }
  }

  override void update(float time) {
  }

  private:
  TextBox _textBox;
  int _charLimit;

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

