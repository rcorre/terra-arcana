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
    _textBuffer = data.get("textBuffer", "0,0").parseVector!int;
    super(data, pos, anchor);
  }

  override void draw(Vector2i parentTopLeft) {
    super.draw(parentTopLeft);
    auto drawPos = area.bottomLeft + parentTopLeft + _textBuffer;
    foreach(post ; _messages) {
      drawPos.y -= _font.heightOf(post.message);
      _font.draw(post.message, drawPos, post.color);
    }
  }

  void postMessage(string message, Color color = Color.black) {
    _messages.insertFront(Post(message, color));
  }

  private:
  Font _font;
  DList!Post _messages;
  Vector2i _textBuffer;

  struct Post {
    string message;
    Color color;
  }
}
