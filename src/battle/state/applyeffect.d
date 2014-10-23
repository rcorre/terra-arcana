module battle.state.applyeffect;

import dau.all;
import model.all;
import battle.battle;
import battle.pathfinder;
import battle.system.all;

/// apply the result of an action
class ApplyEffect : State!Battle {
  this(const UnitAction action, Unit target) {
    _target = target;
    _action = action;
  }

  override {
    void enter(Battle b) {

    }

    void update(Battle b, float time, InputManager input) {
    }

    void draw(Battle b, SpriteBatch sb) {
    }
  }

  private:
  Unit _target;
  const UnitAction _action;
}
