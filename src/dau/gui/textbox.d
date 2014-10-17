module dau.gui.textbox;

import dau.gui.element;
import dau.geometry.all;
import dau.graphics.color;
import dau.graphics.font;

class TextBox : GUIElement {
  this(string text, Font font, Vector2i pos, Color color = Color.black,
      Anchor anchor = Anchor.topLeft)
  {
    _text = text;
    _font = font;
    _color = color;
    Rect2i textArea;
    int width = _font.widthOf(text);
    int height = _font.heightOf(text);
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

  override void draw(Vector2i parentTopLeft) {
    _font.draw(_text, area.topLeft + parentTopLeft);
    super.draw(parentTopLeft);
  }

  private:
  Font _font;
  string _text;
  Color _color;
}
