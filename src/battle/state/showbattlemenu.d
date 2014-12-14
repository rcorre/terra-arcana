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
      auto returnButton = { b.states.popState(); };
      auto exitButton = delegate() { setScene(new Title); };
      _menu = b.gui.addElement(new BattleMenu(returnButton, exitButton));
    }

    void update(Battle b, float time, InputManager input) {
      if (input.exit) {
        b.states.popState();
      }
    }

    void exit(Battle b) {
      _menu.active = false;
    }
  }

  private:
  GUIElement _menu;
}
