module battle.state.undomove;

import dau.all;
import model.all;
import battle.battle;
import battle.system.all;

class UndoMove : State!Battle {
  override {
    void start(Battle b) {
      if (!b.getSystem!UndoMoveSystem.empty) {
        auto undo = b.getSystem!UndoMoveSystem.popMove();
        b.activePlayer.restoreCommandPoints(1);
        undo.unit.tile = undo.tile;
        undo.unit.setAp(undo.ap);
        b.refreshBattlePanel();
      }
      b.states.popState();
    }
  }
}
