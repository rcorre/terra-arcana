module battle.state.performaction;

import dau.all;
import model.all;
import battle.battle;
import battle.pathfinder;
import battle.system.all;

class PerformAction : State!Battle {
  this(Unit actor, int actionNum, Unit target) {
    _actor = actor;
    _actionNum = actionNum;
    _action = actor.getAction(actionNum);
    _target = target;
  }

  override {
    void enter(Battle b) {
      b.disableSystem!TileHoverSystem;
      b.disableSystem!BattleCameraSystem;
      _actor.playAnimation("action%d".format(_actionNum));
    }

    void update(Battle b, float time, InputManager input) {
    }

    void draw(Battle b, SpriteBatch sb) {
    }
  }

  private:
  Unit _actor, _target;
  const UnitAction _action;
  int _actionNum;
}
