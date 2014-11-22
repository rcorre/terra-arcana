module title.state.hostgame;

import dau.all;
import model.all;
import title.title;
import gui.hostscreen;

/// host a network game
class HostGame : State!Title {
  override {
    void enter(Title title) {
      title.gui.clear();
      title.gui.addElement(new HostScreen(title));
    }
  }
}
