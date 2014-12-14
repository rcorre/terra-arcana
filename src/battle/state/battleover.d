module battle.state.battleover;

import std.typecons;
import dau.all;
import model.all;
import title.title;
import battle.battle;
import gui.battleover;
import battle.system.all;

/// player may choose to end turn
class BattleOver : State!Battle {
  this(Flag!"Victory" victory) {
    _victory = victory;
  }

  override {
    void enter(Battle b) {
      b.disableSystem!TileHoverSystem;
      b.gui.addElement(new BattleOverPopup(_victory));
    }

    void update(Battle b, float time, InputManager input) {
      if (input.skip) {
        b.gui.clear();
        setScene(new Title());
      }
    }
  }

  private:
  Flag!"Victory" _victory;
}
