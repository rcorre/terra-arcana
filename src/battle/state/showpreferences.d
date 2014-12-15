module battle.state.showpreferences;

import dau.all;
import model.all;
import battle.battle;
import gui.preferencescreen;

/// player may click on a unit to issue orders
class ShowPreferences : State!Battle {
  override {
    void enter(Battle battle) {
      auto backToBattle = { battle.states.popState(); };
      _menu = battle.gui.addElement(new PreferenceScreen(backToBattle));
    }

    void exit(Battle battle) {
      _menu.active = false;
    }
  }

  private GUIElement _menu;
}
