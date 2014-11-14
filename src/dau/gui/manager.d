module dau.gui.manager;

import dau.setup;
import dau.input;
import dau.gui.element;
import dau.gui.tooltip;
import dau.geometry.all;

class GUIManager {
  ToolTipSpec toolTipSpec;

  this() {
    clear(); // set up initial guielement
  }

  void addElement(GUIElement el) {
    _topElement.addChild(el);
  }

  void clear() {
    _topElement = new GUIElement(Rect2i(0, 0, Settings.screenW, Settings.screenH));
  }

  void update(float time, InputManager input) {
    _topElement.update(time);
    _mousePos = input.mousePos;
    auto underMouse = _topElement.handleMouseHover(input.mousePos, input.prevMousePos);
    if (underMouse != _elementUnderMouse && toolTipSpec !is null) {
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
          _toolTip = new ToolTip(title, text, toolTipSpec,);
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
}
