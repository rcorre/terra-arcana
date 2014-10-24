module battle.state.performcounter;

import dau.all;
import model.all;
import battle.battle;
import battle.pathfinder;
import battle.system.all;
import battle.state.applyeffect;

class PerformCounter : State!Battle {
  this(Unit actor, Unit target) {
    _actor = actor;
    _target = target;
    _actionNum = actor.firstUseableAction(target);
  }

  override {
    void enter(Battle b) {
      if (_actionNum == 0) { // no viable counter attack
        b.states.popState();
      }
      else {
        auto action = _actor.getAction(_actionNum);
        auto onAnimationEnd = delegate() {
          b.states.popState();
          for(int i = 0; i < action.hits; ++i) {
            b.states.pushState(new ApplyEffect(action, _target));
          }
          _actor.consumeAp(action.apCost);
        };
        _actor.playAnimation("action%d".format(_actionNum), onAnimationEnd);
        _effectAnim = _actor.getActionAnimation(_actionNum);
        _actor.getActionSound(_actionNum).play();
      }
    }

    void update(Battle b, float time, InputManager input) {
      _effectAnim.update(time);
    }

    void draw(Battle b, SpriteBatch sb) {
      sb.draw(_effectAnim, _target.center);
    }
  }

  private:
  Unit _actor, _target;
  int _actionNum;
  Animation _effectAnim;
}
