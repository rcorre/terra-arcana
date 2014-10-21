module dau.gui.textbox;

import std.conv;
import dau.gui.element;
import dau.geometry.all;
import dau.graphics.color;
import dau.graphics.font;

class TextBox : GUIElement {
  this(T)(T text, Font font, Vector2i pos, Anchor anchor = Anchor.topLeft,
      Color color = Color.black)
  {
    _text = text.to!string;
    _font = font;
    _color = color;
    Rect2i textArea;
    int width = _font.widthOf(_text);
    int height = _font.heightOf(_text);
    final switch (anchor) with (Anchor) {
      case topLeft:
        textArea = Rect2i(pos, width, height);
        break;
      case center:
        textArea = Rect2i.centeredAt(pos, width, height);
        break;
    }
    super(textArea);
  }

  /// create a textbox with text centered in the specified area
  this(T)(T text, Font font, Rect2i area, Anchor anchor = Anchor.topLeft,
      Color color = Color.black)
  {
    //TODO use for icon text (to make it centered)
  }

  override void draw(Vector2i parentTopLeft) {
    _font.draw(_text, area.topLeft + parentTopLeft);
    super.draw(parentTopLeft);
  }

  private:
  Font _font;
  string _text;
  Color _color;
}
