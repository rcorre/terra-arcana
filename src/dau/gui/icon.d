module dau.gui.icon;

import std.conv, std.algorithm : max;
import dau.gui.element;
import dau.gui.textbox;
import dau.gui.data;
import dau.geometry.all;
import dau.graphics.all;

/// draws a single sprite with a value next to it
class Icon : GUIElement {
  this(GUIData data) {
    auto pos = data.get("offset", "0,0").parseVector!int;
    auto anchor = data.get("anchor", "topLeft").to!Anchor;
    super(data, pos, anchor);
    if ("text" in data.child) {
      addChild(new TextBox(data.child["text"]));
    }
  }

  this(GUIData data, Vector2i pos, Anchor anchor = Anchor.topLeft) {
    super(data, pos, anchor);
  }

  this(T)(GUIData iconData, GUIData textData, Vector2i pos, T text, Anchor anchor = Anchor.topLeft) {
    auto icon = new Icon(iconData, Vector2i.zero, anchor);
    auto textbox = new TextBox(textData, text, Vector2i(icon.width, 0), anchor);
    super(iconData, Rect2i(pos, icon.width + textbox.width, max(icon.height, textbox.height)));
    addChild(icon);
    addChild(textbox);
  }
}
