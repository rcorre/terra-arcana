module title.state.showcredits;

import dau.all;
import title.title;
import gui.credits;

/// player may click on a unit to issue orders
class ShowCredits : State!Title {
  override {
    void enter(Title title) {
      title.gui.clear();
      title.gui.addElement(new CreditsScreen(title));
    }
  }
}
