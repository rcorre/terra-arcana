module dau.gui.manager;

import dau.setup;
import dau.input;
import dau.gui.element;
import dau.gui.tooltip;
import dau.gui.data;
import dau.geometry.all;
import dau.graphics.cursor;

class GUIManager {
  this() {
    clear(); // set up initial guielement
  }

  void manageCursor(CursorManager cursor, string inactiveCursorSprite, string activeCursorSprite) {
    _cursor = cursor;
    _inactiveCursorSprite = inactiveCursorSprite;
    _activeCursorSprite = activeCursorSprite;
  }

  void addElement(GUIElement el) {
    _topElement.addChild(el);
  }

  void clear() {
    _topElement = new GUIElement(new GUIData, Rect2i(0, 0, Settings.screenW, Settings.screenH));
  }

  void update(float time, InputManager input) {
    _topElement.update(time);
    _mousePos = input.mousePos;
    bool highlight; // whether to highlight mouse
    auto underMouse = _topElement.handleMouseHover(input.mousePos, input.prevMousePos, highlight);
    if (underMouse != _elementUnderMouse) {
      adjustCursor(highlight);
      _elementUnderMouse = underMouse;
      if (underMouse is null) {
        _toolTip = null;
      }
      else {
        auto text = underMouse.toolTipText;
        auto title = underMouse.toolTipTitle;
        if (text is null && title is null) {
          _toolTip = null;
        }
        else {
          _toolTip = new ToolTip(title, text);
        }
      }
    }
    if (input.select) {
      _topElement.handleMouseClick(input.mousePos);
    }
  }

  void draw() {
    _topElement.draw(Vector2i.zero);
    if (_toolTip !is null) {
      _toolTip.draw(_mousePos);
    }
  }

  private:
  GUIElement _topElement;
  GUIElement _elementUnderMouse;
  ToolTip _toolTip;
  Vector2i _mousePos;
  CursorManager _cursor;
  string _inactiveCursorSprite, _activeCursorSprite;

  void adjustCursor(bool active) {
    if (_cursor !is null) {
      _cursor.setSprite(active ? _activeCursorSprite : _inactiveCursorSprite);
    }
  }
}
