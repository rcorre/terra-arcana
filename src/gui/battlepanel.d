module gui.battlepanel;

import std.string;
import dau.setup;
import dau.geometry.all;
import dau.graphics.all;
import dau.gui.all;
import gui.unitinfo;
import model.all;

private enum {
  spriteName       = "gui/battle_panel",
  iconSheetName    = "gui/icons",
  leftUnitOffset = Vector2i(108, 7),
  rightUnitOffset = Vector2i(446, 10)
}

/// bar that displays progress as discrete elements (pips)
class BattlePanel : GUIElement {
  this() {
    auto background = new Sprite(spriteName);
    super(background, Vector2i(0, Settings.screenH - background.height));
    setLeftUnitInfo(null);
    setRightUnitInfo(null);
  }

  void setLeftUnitInfo(Unit unit) {
    if (_leftUnitInfo !is null) {
      _leftUnitInfo.active = false;
    }
    _leftUnitInfo = addChild(new UnitInfoGUI(unit, leftUnitOffset));
  }

  void setRightUnitInfo(Unit unit) {
    if (_rightUnitInfo !is null) {
      _rightUnitInfo.active = false;
    }
    _rightUnitInfo = addChild(new UnitInfoGUI(unit, rightUnitOffset));
  }

  private:
  TextBox _commandCounter, _manaCounter;
  GUIElement _leftUnitInfo, _rightUnitInfo;
}

private:
Font _font;

static this() {
  onInit({ _font = Font("Mecha", 20); });
}
