module title.state.showinstructions;

import dau.all;
import model.all;
import title.title;
import gui.instructions;

/// player may click on a unit to issue orders
class ShowInstructions : State!Title {
  override {
    void enter(Title title) {
      title.gui.clear();
      auto backToTitle = { title.states.popState(); };
      title.gui.addElement(new InstructionScreen(backToTitle));
    }
  }
}
