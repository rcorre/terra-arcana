module gui.unitinfo;

import std.string;
import dau.setup;
import dau.geometry.all;
import dau.graphics.all;
import dau.gui.all;
import model.unit;

private enum {
  spriteName       = "gui/unit_status",
  pipName          = "gui/pip",
  armorOffset      = Vector2i(21, 53),
  evadeOffset      = Vector2i(180, 53),
  hpArea           = Rect2i(41, 37, 63, 13),
  apArea           = Rect2i(108, 37, 51, 13),
  statOffset       = Vector2i(41, 53),
  actionBarOffset1 = Vector2i(0, 77),
  actionBarOffset2 = Vector2i(0, 105),
  actionBarSize    = Vector2i(200, 24),
  iconSheetName    = "gui/icons"
}

/// bar that displays progress as discrete elements (pips)
class UnitInfoGUI : GUIElement {
  this(Unit unit) {
    // TODO: choose corner of unit based on screen positioning
    super(new Sprite(spriteName), unit.area.bottomRight);
    _hpBar = new PipBar(hpArea, unit.maxHp, pipName, "hpPip");
    _apBar = new PipBar(apArea, unit.maxAp, pipName, "apPip");
    _armorText = new TextBox(unit.baseArmor, _font, armorOffset, GUIElement.Anchor.center);
    _evadeText = new TextBox(unit.baseEvade, _font, evadeOffset, GUIElement.Anchor.center);
    addChild(_hpBar);
    addChild(_apBar);
    addChild(_armorText);
    addChild(_evadeText);
    addChild(new ActionInfo(actionBarOffset1, unit.action1));
    addChild(new ActionInfo(actionBarOffset2, unit.action2));
  }

  private:
  PipBar _hpBar, _apBar;
  TextBox _armorText, _evadeText;
  ActionInfo _actionInfo1, _actionInfo2;
}

private:
class ActionInfo : GUIElement {
  private enum {
    actionIconOffset = Vector2i(4, 4),
    iconSeparation = 4,
  }

  this(Vector2i topLeft, const UnitAction action) {
    super(Rect2i(topLeft, actionBarSize));
    auto actionName = action.name.toLower;
    addChild(new Icon(new Sprite(iconSheetName, actionName), actionIconOffset));
  }
}

Font _font;

static this() {
  onInit({ _font = Font("Mecha", 14); });
}
