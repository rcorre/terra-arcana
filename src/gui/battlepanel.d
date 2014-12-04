module gui.battlepanel;

import std.string;
import dau.setup;
import dau.geometry.all;
import dau.graphics.all;
import dau.gui.all;
import gui.unitinfo;
import gui.slideawaypanel;
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

    _leftCommand  = addPanel("leftCommand");
    _leftMana     = addPanel("leftMana");
    _rightCommand = addPanel("rightCommand");
    _rightMana    = addPanel("rightMana");
  }

  void setCommandCounter(int val, int max) {
    //_leftCommand.text.text = cmdFormat.format(val, max);
  }

  void setManaCounter(int val) {
    //_leftMana.text.text = manaFormat.format(val);
  }

  private:
  SlideAwayPanel _leftCommand, _leftMana;
  SlideAwayPanel _rightCommand, _rightMana;

  auto addPanel(string name) {
    auto panelData = data.child[name];
    auto icon = new Icon(panelData.child["icon"]);
    auto textBox = new TextBox(panelData.child["text"]);
    return addChild(new SlideAwayPanel(panelData, icon, textBox));
  }
}
