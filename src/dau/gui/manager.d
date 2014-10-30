module dau.gui.manager;

import dau.setup;
import dau.input;
import dau.gui.element;
import dau.geometry.all;

class GUIManager {
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
    _topElement.handleMouseHover(input.mousePos, input.prevMousePos);
    if (input.select) {
      _topElement.handleMouseClick(input.mousePos);
    }
  }

  void draw() {
    _topElement.draw(Vector2i.zero);
  }

  private:
  GUIElement _topElement;
}
