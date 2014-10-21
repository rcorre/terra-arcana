module gui.unitinfo;

import dau.setup;
import dau.geometry.all;
import dau.graphics.all;
import dau.gui.all;
import model.unit;

private enum {
  spriteName  = "gui/unit_status",
  armorOffset = Vector2i(21, 53),
  evadeOffset = Vector2i(180, 53),
  hpArea      = Rect2i(41, 37, 63, 13),
  apArea      = Rect2i(108, 37, 51, 13),
  statOffset  = Vector2i(41, 53),
  actionBarOffset1  = Vector2i(0, 77),
  actionBarOffset2  = Vector2i(0, 105),
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
  ActionInfo _actionInfo1, _actionInfo2;
}

private class ActionInfo {
  private enum {
    iconSeparation = 4,
  }

  this(Vector2i topLeft, UnitAction action) {
  }
  private:
  Sprite _icon;
}

private:
Font _font;

static this() {
  onInit({ _font = Font("Mecha", 14); });
}
