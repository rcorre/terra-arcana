module dau.gui.tooltip;

import dau.setup;
import dau.gui.element;
import dau.gui.textbox;
import dau.geometry.all;
import dau.graphics.all;

class ToolTip : GUIElement {
  this(string title, string text, ToolTipSpec spec) {
    auto sprite =
    super(new Sprite(spec.spriteName), Vector2i.zero, Anchor.topLeft);
    addChild(new TextBox(title, spec.titleFont, spec.titleOffset));
    addChild(new TextBox(text, spec.textFont, spec.textOffset));
  }
}

class ToolTipSpec {
  string spriteName;
  Font titleFont;
  Font textFont;
  Vector2i titleOffset;
  Vector2i textOffset;
}
