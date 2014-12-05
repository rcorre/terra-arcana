module gui.battlepanel;

import dau.setup;
import dau.geometry.all;
import dau.graphics.all;
import dau.gui.all;
import gui.slideawaypanel;
import model.all;

/// bar that displays progress as discrete elements (pips)
class BattlePanel : SlideAwayPanel {
  this() {
    auto data = getGUIData("battlePanel");
    super(data);

    _commandBar = addChild(new PipBar(data.child["commandBar"]));
    _manaBar    = addChild(new PipBar(data.child["manaBar"]));
  }

  void refresh(Player player) {
    _manaBar.setVal(player.mana);
    _commandBar.setVal(player.commandPoints);
  }

  private:
  PipBar _commandBar, _manaBar;
}
