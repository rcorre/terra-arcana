module gui.tooltip;

import dau.all;

private enum {
  spriteName  = "gui/tooltip",
  titleFont   = "Mecha_Bold",
  textFont    = "Mecha_Condensed",
  titleSize   = 28,
  textSize    = 20,
  titleOffset = Vector2i(43, 11),
  textOffset  = Vector2i(7, 43),
}

class ToolTip : GUIElement {
  this(Vector2i pos, string title, string text) {
    auto sprite = new Sprite(spriteName);
    super(sprite, pos, Anchor.topLeft);
    addChild(new TextBox(title, _titleFont, titleOffset));
    addChild(new TextBox(text, _textFont, textOffset));
  }
}

private:
Font _titleFont, _textFont;

static this() {
  auto loadFonts = function() {
    _titleFont = Font(titleFont, titleSize);
    _textFont = Font(textFont, textSize);
  };
  onInit(loadFonts);
}
