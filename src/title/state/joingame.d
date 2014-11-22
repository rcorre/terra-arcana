module title.state.joingame;

import dau.all;
import model.all;
import title.title;
import gui.joinscreen;

/// join a network game
class JoinGame : State!Title {
  override {
    void enter(Title title) {
      title.gui.clear();
      title.gui.addElement(new JoinScreen(title));
    }
  }
}
