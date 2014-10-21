module dau.gui.icon;

import std.algorithm : max;
import dau.gui.element;
import dau.gui.textbox;
import dau.geometry.all;
import dau.graphics.all;

/// draws a single sprite with a value next to it
class Icon : GUIElement {
  this(Sprite sprite, Vector2i pos, Anchor anchor = Anchor.topLeft) {
    super(sprite, pos, anchor);
  }

  this(T)(Sprite sprite, Vector2i pos, T text, Font font, Anchor anchor = Anchor.topLeft) {
    auto icon = new Icon(sprite, Vector2i.zero, anchor);
    auto textbox = new TextBox(text, font, Vector2i(sprite.width, 0), anchor);
    super(Rect2i(pos, icon.width + textbox.width, max(icon.height, textbox.height)));
    addChild(icon);
    addChild(textbox);
  }
}
