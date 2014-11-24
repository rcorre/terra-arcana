module dau.gui.messagebox;

import std.conv, std.container : DList;
import dau.gui.element;
import dau.gui.data;
import dau.geometry.all;
import dau.graphics.all;

class MessageBox : GUIElement {
  this(GUIData data) {
    _font = Font(data["fontName"], data["fontSize"].to!int);
    auto pos = data.get("offset", "0,0").parseVector!int;
    auto anchor = data.get("anchor", "topLeft").to!Anchor;
    super(data, pos, anchor);
  }

  override void draw(Vector2i parentTopLeft) {
    super.draw(parentTopLeft);
    auto drawPos = area.bottomLeft + parentTopLeft;
    foreach(message ; _messages) {
      drawPos.y -= _font.heightOf(message);
      auto color = Color.black;
      _font.draw(message, drawPos, color);
    }
  }

  void postMessage(string message) {
    _messages.insertFront(message);
  }

  private:
  Font _font;
  DList!string _messages;
}
