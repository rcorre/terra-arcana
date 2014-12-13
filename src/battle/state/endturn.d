module battle.state.endTurn;

import dau.all;
import model.all;
import gui.endturn;
import battle.battle;
import battle.system.all;

/// player may choose to end turn
class EndTurn : State!Battle {
  override {
    void enter(Battle b) {
      b.disableSystem!TileHoverSystem;
      _popup = b.gui.addElement(new EndTurnPopup());
    }

    void update(Battle b, float time, InputManager input) {
      if (input.select) {
        b.states.popState();
      }
      else if (input.skip) {
        b.states.popState();
        b.startNewTurn;
        b.getSystem!BattleNetworkSystem.broadcastEndTurn(); // notify network
      }
    }

    void exit(Battle b) {
      _popup.active = false;
      _popup.active = false;
    }
  }

  private:
  GUIElement _popup;
}
