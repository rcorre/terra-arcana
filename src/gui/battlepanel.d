module gui.battlepanel;

import std.string;
import dau.setup;
import dau.geometry.all;
import dau.graphics.all;
import dau.gui.all;
import gui.unitinfo;
import model.all;

private enum {
  spriteName           = "gui/battle_panel",
  iconSheetName        = "gui/icons",
  leftUnitOffset       = Vector2i(108, 7),
  rightUnitOffset      = Vector2i(446, 10),
  commandCounterOffset = Vector2i(46, 21),
  manaCounterOffset    = Vector2i(46, 70),
  commandFormat        = "%d/%d",
  manaFormat           = "%d"
}

/// bar that displays progress as discrete elements (pips)
class BattlePanel : GUIElement {
  this() {
    auto background = new Sprite(spriteName);
    super(background, Vector2i(0, Settings.screenH - background.height));
    setLeftUnitInfo(null);
    setRightUnitInfo(null);
    _commandCounter = new TextBox(commandFormat.format(0, 0), _font, commandCounterOffset);
    _manaCounter = new TextBox(manaFormat.format(0), _font, manaCounterOffset);
    addChildren(_commandCounter, _manaCounter);
  }

  @property auto leftUnitInfo() { return _leftUnitInfo; }
  @property auto rightUnitInfo() { return _rightUnitInfo; }

  void setLeftUnitInfo(Unit unit) {
    if (_leftUnitInfo !is null) {
      _leftUnitInfo.active = false;
    }
    _leftUnitInfo = new UnitInfoGUI(unit, leftUnitOffset);
    addChild(_leftUnitInfo);
  }

  void setRightUnitInfo(Unit unit) {
    if (_rightUnitInfo !is null) {
      _rightUnitInfo.active = false;
    }
    _rightUnitInfo = new UnitInfoGUI(unit, rightUnitOffset);
    addChild(_rightUnitInfo);
  }

  void setCommandCounter(int val, int max) {
    _commandCounter.text = commandFormat.format(val, max);
  }

  void setManaCounter(int val) {
    _manaCounter.text = manaFormat.format(val);
  }

  private:
  TextBox _commandCounter, _manaCounter;
  UnitInfoGUI _leftUnitInfo, _rightUnitInfo;
}

private:
Font _font;

static this() {
  onInit({ _font = Font("Mecha", 20); });
}
