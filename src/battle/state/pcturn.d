module battle.state.pcturn;

import dau.all;
import model.all;
import battle.ai.all;
import battle.battle;
import battle.system.all;
import battle.state.moveunit;
import battle.state.performaction;
import battle.state.deployunit;

/// the AI may begin moving units
class PCTurn : State!Battle {
  this(Player pc) {
    _pc = cast(AIPlayer) pc;
    assert(_pc !is null, "tried to start pc turn with player that is not AI");
  }

  override {
    void enter(Battle b) {
      b.disableSystem!TileHoverSystem;
      b.enableSystem!BattleCameraSystem;
      if (_pc.commandPoints == 0) {
        b.startNewTurn;
        return;
      }

      auto decision = _pc.getDecision(b);
      if (decision is null) {
        b.startNewTurn;
      }

      auto deploy = cast(DeployOption) decision;
      if (deploy !is null) {
        b.states.pushState(new DeployUnit(_pc, deploy.target, deploy.unitKey));
      }

      auto move = cast(MoveOption) decision;
      if (move !is null) {
        b.states.pushState(new MoveUnit(move.unit, move.path));
      }

      auto action = cast(ActOption) decision;
      if (action !is null) {
        b.states.pushState(new PerformAction(action.unit, action.actionNum, action.target));
      }
    }
  }

  private:
  AIPlayer _pc;
}
