module title.state.selectbattle;

import dau.all;
import model.all;
import title.title;
import gui.battleselectionscreen;

/// player may click on a unit to issue orders
class SelectBattle : State!Title {
  override {
    void enter(Title title) {
      title.gui.clear();
      title.gui.addElement(new BattleSelectionScreen);
    }
  }
}
