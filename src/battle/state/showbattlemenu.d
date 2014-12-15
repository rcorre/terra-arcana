module battle.state.showbattlemenu;

import dau.all;
import title.title;
import battle.battle;
import battle.system.all;
import gui.battlemenu;

/// player may click on a unit to issue orders
class ShowBattleMenu : State!Battle {
  override {
    void enter(Battle b) {
      b.disableSystem!TileHoverSystem;
      b.disableSystem!BattleCameraSystem;
      _menu = b.gui.addElement(new BattleMenu(b));
    }

    void update(Battle b, float time, InputManager input) {
      if (input.exit) {
        b.states.popState();
      }
    }

    void exit(Battle b) {
      _menu.active = false;
      if (!Preferences.fetch.showInputHints) {
        b.getSystem!InputHintSystem.hideHints();
      }
    }
  }

  private:
  GUIElement _menu;
}
