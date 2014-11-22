module title.state.showtitle;

import dau.all;
import model.all;
import title.title;
import gui.titlescreen;

/// player may click on a unit to issue orders
class ShowTitle : State!Title {
  override {
    void enter(Title title) {
      title.gui.clear();
      title.gui.addElement(new TitleScreen(title));
    }
  }
}
