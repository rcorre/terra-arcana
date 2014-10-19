module gui.unitinfo;

import dau.setup;
import dau.geometry.all;
import dau.graphics.all;
import dau.gui.all;
import model.unit;

private enum {
  spriteName  = "gui/unit_status",
  armorOffset = Vector2i(29, 29),
  evadeOffset = Vector2i(229, 29),
  hpArea      = Rect2i(56, 8, 141, 21),
  apArea      = Rect2i(56, 32, 77, 21),
}

/// bar that displays progress as discrete elements (pips)
class UnitInfoGUI : GUIElement {
  this(Unit unit) {
    // TODO: choose corner of unit based on screen positioning
    super(new Sprite("gui/unit_status"), unit.area.bottomRight);
    _hpBar = new PipBar(hpArea, unit.maxHp, "gui/pip", "hpPip");
    _apBar = new PipBar(apArea, unit.maxAp, "gui/pip", "apPip");
    _armorText = new TextBox(unit.baseArmor, _font, armorOffset, GUIElement.Anchor.center);
    _evadeText = new TextBox(unit.baseEvade, _font, evadeOffset, GUIElement.Anchor.center);
    addChild(_hpBar);
    addChild(_apBar);
    addChild(_armorText);
    addChild(_evadeText);
  }

  private:
  PipBar _hpBar, _apBar;
  TextBox _armorText, _evadeText;
}

private:
Font _font;

static this() {
  onInit({ _font = Font("Mecha_Bold", 16); });
}

// TODO:
// show dimmed pips
// dau font
// dau gui textbox
