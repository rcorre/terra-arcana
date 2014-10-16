module gui.unitinfo;

import dau.geometry.all;
import dau.graphics.all;
import dau.gui.all;
import model.unit;

private enum {
  spriteName = "gui/unit_status"
}

/// bar that displays progress as discrete elements (pips)
class UnitInfoGUI : GUIElement {
  this(Unit unit) {
    // TODO: choose corner of unit based on screen positioning
    super(new Sprite("gui/unit_status"), unit.area.bottomRight);
  }
}
