module title.state.editpreferences;

import dau.all;
import model.all;
import title.title;
import gui.preferencescreen;

/// player may click on a unit to issue orders
class EditPreferences : State!Title {
  override {
    void enter(Title title) {
      title.gui.clear();
      auto backToTitle = { title.states.popState(); };
      title.gui.addElement(new PreferenceScreen(backToTitle));
    }
  }
}
