module battle.state.pcturn;

import std.array;
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
      b.cursor.setSprite("wait");
      b.disableSystem!TileHoverSystem;
      b.enableSystem!BattleCameraSystem;
      if (_pc.commandPoints == 0) {
        b.startNewTurn;
        return;
      }

      auto decision = _pc.getDecision(b);
      if (decision is null) {
        b.startNewTurn;
        return;
      }

      final switch (decision.type) with (AIDecision.Type) {
        case deploy:
          auto dd = cast(DeployDecison) decision;
          b.states.pushState(new DeployUnit(_pc, dd.location, dd.unitKey));
          break;
        case move:
          auto md = cast(MoveDecison) decision;
          b.states.pushState(new MoveUnit(md.unit, md.path));
          break;
        case action:
          auto ad = cast(ActDecison) decision;
          b.states.pushState(new PerformAction(ad.actor, ad.actionNum, ad.target));
          if (ad.movePath !is null && !ad.movePath.empty) {
            b.states.pushState(new MoveUnit(ad.actor, ad.movePath));
          }
          break;
      }
    }

    void end(Battle b) {
      b.cursor.setSprite("inactive");
    }
  }

  private:
  AIPlayer _pc;
}
