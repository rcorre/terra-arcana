module dau.gui.icon;

import dau.gui.element;
import dau.geometry.all;
import dau.graphics.color;
import dau.graphics.font;

/// draws a single sprite with a value next to it
class Icon : GUIElement {
  this(Sprite sprite, Vector2i pos, Anchor anchor = Anchor.topLeft) {
    super(sprite, pos, anchor)
  }

  this(T)(Sprite sprite, Vector2i pos, Anchor anchor = Anchor.topLeft, T text, Font font) {
    _text = text.to!string;
    _font = font;
    auto textPos = Vector2i(sprite.width, 0);
    addChild(new TextBox(text, font, textPos, anchor));
  }
}
