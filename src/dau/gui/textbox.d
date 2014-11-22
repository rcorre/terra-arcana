module dau.gui.textbox;

import std.conv;
import dau.gui.element;
import dau.gui.data;
import dau.geometry.all;
import dau.graphics.color;
import dau.graphics.font;

class TextBox : GUIElement {
  this(GUIData data) {
    auto text = data.get("text", "");
    auto pos = data.get("offset", "0,0").parseVector!int;
    auto anchor = data.get("anchor", "topLeft").to!Anchor;
    this(data, text, pos, anchor);
  }

  this(T)(GUIData data, T text, Vector2i pos, Anchor anchor = Anchor.topLeft) {
    _text = text.to!string;
    _font = Font(data["fontName"], data["fontSize"].to!int);
    _color = parseColor(data.get("textColor", "0,0,0"));
    Rect2i area;
    int width = _font.widthOf(_text);
    int height = _font.heightOf(_text);
    final switch (anchor) with (Anchor) {
      case topLeft:
        area = Rect2i(pos, width, height);
        break;
      case center:
        area = Rect2i.centeredAt(pos, width, height);
        break;
    }
    super(data, area);
  }

  @property {
    auto text() { return _text; }
    void text(string text) { _text = text; }

    /// return the actual area covered by the text
    auto textArea() {
      return Rect2i(area.topLeft, _font.widthOf(_text), _font.heightOf(_text));
    }
  }

  override void draw(Vector2i parentTopLeft) {
    _font.draw(_text, area.topLeft + parentTopLeft, _color);
    super.draw(parentTopLeft);
  }

  private:
  Font _font;
  string _text;
  Color _color;
}
