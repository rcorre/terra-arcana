module gui.battlepanel;

import std.string;
import dau.setup;
import dau.geometry.all;
import dau.graphics.all;
import dau.gui.all;
import gui.unitinfo;
import model.all;

private enum {
  cmdFormat  = "%d/%d",
  manaFormat = "%d"
}

/// bar that displays progress as discrete elements (pips)
class BattlePanel : GUIElement {
  this() {
    auto data = getGUIData("battlePanel");
    auto background = new Sprite(data["texture"]);
    super(data, Vector2i(0, Settings.screenH - background.height));
    setLeftUnitInfo(null);
    setRightUnitInfo(null);
    auto cmdCounterOffset = data["commandCounterOffset"].parseVector!int;
    auto manaCounterOffset = data["manaCounterOffset"].parseVector!int;
    _commandCounter = new TextBox(data.child["counter"], cmdFormat.format(0, 0), cmdCounterOffset);
    _manaCounter = new TextBox(data.child["counter"], manaFormat.format(0), manaCounterOffset);
    addChildren(_commandCounter, _manaCounter);
  }

  @property auto leftUnitInfo() { return _leftUnitInfo; }
  @property auto rightUnitInfo() { return _rightUnitInfo; }

  void setLeftUnitInfo(Unit unit) {
    if (_leftUnitInfo !is null) {
      _leftUnitInfo.active = false;
    }
    _leftUnitInfo = new UnitInfoGUI(unit, data["leftUnitOffset"].parseVector!int);
    addChild(_leftUnitInfo);
  }

  void setRightUnitInfo(Unit unit) {
    if (_rightUnitInfo !is null) {
      _rightUnitInfo.active = false;
    }
    _rightUnitInfo = new UnitInfoGUI(unit, data["rightUnitOffset"].parseVector!int);
    addChild(_rightUnitInfo);
  }

  void setCommandCounter(int val, int max) {
    _commandCounter.text = cmdFormat.format(val, max);
  }

  void setManaCounter(int val) {
    _manaCounter.text = manaFormat.format(val);
  }

  private:
  TextBox _commandCounter, _manaCounter;
  UnitInfoGUI _leftUnitInfo, _rightUnitInfo;
}
