module gui.unitinfo;

import dau.geometry.all;
import dau.graphics.all;
import dau.gui.all;
import model.unit;

private enum {
  spriteName  = "gui/unit_status",
  armorOffset = Vector2i(25, 21),
  evadeOffset = Vector2i(224, 36),
  hpArea      = Rect2i(56, 8, 141, 21),
  apArea      = Rect2i(56, 24, 77, 21),
}

/// bar that displays progress as discrete elements (pips)
class UnitInfoGUI : GUIElement {
  this(Unit unit) {
    // TODO: choose corner of unit based on screen positioning
    super(new Sprite("gui/unit_status"), unit.area.bottomRight);
    addChild(new PipBar(hpArea, unit.maxHp, new Sprite("gui/hpPip")));
  }
}

// TODO:
// add pip bars to unitinfo
// dau font
// dau gui textbox
