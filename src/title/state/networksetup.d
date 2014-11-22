module title.state.networksetup;

import dau.all;
import model.all;
import title.title;
import gui.networkscreen;

/// player may click on a unit to issue orders
class NetworkSetup : State!Title {
  override {
    void enter(Title title) {
      title.gui.clear();
      title.gui.addElement(new NetworkScreen(title));
    }
  }
}
