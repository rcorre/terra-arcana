module dau.gui.tooltip;

import dau.setup;
import dau.gui.element;
import dau.gui.textbox;
import dau.gui.data;
import dau.geometry.all;
import dau.graphics.all;

class ToolTip : GUIElement {
  this(string title, string text) {
    super(getGUIData("toolTip"), Vector2i.zero, Anchor.topLeft);
    auto titleCenter = data["titleCenter"].parseVector!int;
    auto textOffset = data["textOffset"].parseVector!int;
    addChild(new TextBox(data.child["title"], title, titleCenter, Anchor.center));
    addChild(new TextBox(data.child["text"], text, textOffset));
  }
}
