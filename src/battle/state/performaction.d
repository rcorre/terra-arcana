module battle.state.performaction;

import dau.all;
import model.all;
import battle.battle;
import battle.pathfinder;
import battle.system.all;
import battle.state.performcounter;
import battle.state.applyeffect;
import battle.state.applybuff;
import battle.state.checkunitdestruction;

private enum apBarFadeDuration = 0.2f;

class PerformAction : State!Battle {
  this(Unit actor, int actionNum, Unit target) {
    _actor = actor;
    _actionNum = actionNum;
    _action = actor.getAction(actionNum);
    _target = target;
  }

  override {
    void start(Battle b) {
      b.disableSystem!TileHoverSystem;
      // place actor in left unit info slot, target in right
      b.lockLeftUnitInfo = false;
      b.displayUnitInfo(_actor);
      b.lockLeftUnitInfo = true;
      b.displayUnitInfo(_target);
      // trigger new state once animation ends
      void delegate() onAnimationEnd = null;
      if (_actor.team == _target.team) {
        onAnimationEnd = delegate() {
          b.states.setState(new ApplyBuff(_action, _target));
        };
      }
      else { // offensive ability
        onAnimationEnd = delegate() {
          b.states.popState();
          b.states.pushState(new CheckUnitDestruction(_actor));
          b.states.pushState(new CheckUnitDestruction(_target));
          b.states.pushState(new PerformCounter(_target, _actor));
          for(int i = 0; i < _action.hits; ++i) {
            b.states.pushState(new ApplyEffect(_action, _target));
          }
        };
      }
      // play animation and sound
      _actor.playAnimation("action%d".format(_actionNum), onAnimationEnd);
      _effectAnim = _actor.getActionAnimation(_actionNum);
      _actor.getActionSound(_actionNum).play();

      // drain ap and animate ap change
      auto ui = b.unitInfoFor(_actor);
      int prevAp = _actor.ap;
      _actor.consumeAp(_action.apCost);
      b.activePlayer.consumeCommandPoints(1);
      b.updateBattlePanel();
      ui.animateApChange(prevAp, _actor.ap, apBarFadeDuration);
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
  const UnitAction _action;
  int _actionNum;
  Animation _effectAnim;
}
