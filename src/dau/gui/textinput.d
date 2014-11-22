module dau.gui.textinput;

import std.conv, std.string;
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

    registerEventHandler(&handleKeyChar, ALLEGRO_EVENT_KEY_CHAR);
  }

  @property {
    string text() { return _textBox.text; }
    void text(string val) {
      _textBox.text = val;
    }
  }

  override void update(float time) {
  }

  private:
  TextBox _textBox;

  void handleKeyChar(ALLEGRO_EVENT event) {
    if (event.keyboard.keycode == ALLEGRO_KEY_BACKSPACE) {
      _textBox.text = _textBox.text.chop;
    }
    else {
      _textBox.text = _textBox.text ~ cast(char) event.keyboard.unichar;
    }
  }
}

