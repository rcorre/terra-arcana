module battle.state.applyeffect;

import dau.all;
import model.all;
import battle.battle;
import battle.pathfinder;
import battle.system.all;

private enum waitTime = 0.2f;

/// apply the result of a single hit of an action
class ApplyEffect : State!Battle {
  this(const UnitAction action, Unit target) {
    _target = target;
    _action = action;
    _timer = waitTime;
  }

  override { // TODO: show effect on status bar
    void enter(Battle b) {
      bool hit = _target.evade == 0 || _action.hasSpecial(UnitAction.Special.precise);
      if (hit) {
        switch (_action.effect) with (UnitAction.Effect) {
          case damage:
            _target.dealDamage(_action.power);
            break;
          default:
            assert(0, "no code to handle effect type");
        }
      }
      else {
        _target.dodgeAttack();
      }
    }

    void update(Battle b, float time, InputManager input) {
      _timer -= time;
      if (_timer < 0) {
        b.states.popState();
      }
    }

    void draw(Battle b, SpriteBatch sb) {
    }

    void exit(Battle b) {
    }
  }

  private:
  Unit _target;
  const UnitAction _action;
  float _timer;
}
