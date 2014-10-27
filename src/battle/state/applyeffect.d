module battle.state.applyeffect;

import dau.all;
import model.all;
import battle.battle;
import battle.pathfinder;
import battle.system.all;
import battle.state.delay;

/// apply the result of a single hit of an action
class ApplyEffect : State!Battle {
  this(const UnitAction action, Unit target) {
    _target = target;
    _action = action;
  }

  override { // TODO: show effect on status bar
    void enter(Battle b) {
      bool hit = _target.evade == 0 || _action.hasSpecial(UnitAction.Special.precise);
      if (hit) {
        switch (_action.effect) with (UnitAction.Effect) {
          case damage:
            _target.dealDamage(_action.power);
            break;
          case stun:
            _target.damageAp(_action.power);
            break;
          case evade:
            _target.adjustEvade(_action.power);
            break;
          case armor:
            _target.adjustEvade(_action.power);
            break;
          case toxin:
            _target.applyToxin(_action.power);
            break;
          default:
            assert(0, "no code to handle effect type");
        }
      }
      else {
        _target.dodgeAttack();
      }
      b.states.setState(new Delay); // pause briefly after applying effect
    }
  }

  private:
  Unit _target;
  const UnitAction _action;
}
