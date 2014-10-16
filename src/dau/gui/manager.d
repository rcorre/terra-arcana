module dau.gui.manager;

import dau.engine;
import dau.gui.element;
import dau.geometry.all;

void addGUIElement(GUIElement el) {
  _topElement.addChild(el);
}

void clearGUI() {
  _topElement = new GUIElement(Rect2i(0, 0, Settings.screenW, Settings.screenH));
}

void updateGUI(float time) {
  _topElement.update(time);
}

void drawGUI() {
  _topElement.draw(Vector2i.zero);
}

private:
GUIElement _topElement;

static this() {
  onInit({ clearGUI(); }); // set up initial guielement
}
