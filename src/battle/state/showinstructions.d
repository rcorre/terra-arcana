module battle.state.showinstructions;

import dau.all;
import model.all;
import battle.battle;
import gui.instructions;

/// player may click on a unit to issue orders
class ShowInstructions : State!Battle {
  override {
    void enter(Battle battle) {
      auto backToBattle = { battle.states.popState(); };
      _menu = battle.gui.addElement(new InstructionScreen(backToBattle));
    }

    void exit(Battle battle) {
      _menu.active = false;
    }
  }

  private GUIElement _menu;
}
