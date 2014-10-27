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
  iconSheetName    = "gui/icons"
}

/// bar that displays progress as discrete elements (pips)
class BattlePanel : GUIElement {
  this() {
    auto background = new Sprite(spriteName);
    super(background, Vector2i(0, Settings.screenH - sprite.height));
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
