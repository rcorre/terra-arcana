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
    super(data, Rect2i(0, 0, Settings.screenW, Settings.screenH));

    _leftCommand = addChild(new BattlePanelCounter(data.child["leftCommand"]));
    _leftMana    = addChild(new BattlePanelCounter(data.child["leftMana"]));
  }

  void setCommandCounter(int val, int max) {
    _leftCommand.text.text = cmdFormat.format(val, max);
  }

  void setManaCounter(int val) {
    _leftMana.text.text = manaFormat.format(val);
  }

  private:
  BattlePanelCounter _leftCommand, _leftMana;
  BattlePanelCounter _rightCommand, _rightMana;
}

private class BattlePanelCounter : GUIElement {
  TextBox text;

  this(GUIData data) {
    super(data);
    addChild(new Icon(data.child["icon"]));
    text = addChild(new TextBox(data.child["text"]));
  }
}
