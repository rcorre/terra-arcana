module battle.state.applyeffect;

import dau.all;
import model.all;
import battle.battle;
import battle.pathfinder;
import battle.system.all;
import battle.state.delay;
import gui.battlepopup;

private enum delayDuration = 0.2f;

/// apply the result of a single hit of an action
class ApplyEffect : State!Battle {
  this(const UnitAction action, Unit target) {
    _target = target;
    _action = action;
  }

  override {
    void enter(Battle b) {
      bool hit = _target.evade == 0 || _action.hasSpecial(UnitAction.Special.precise);
      int effectAmount = _action.power;
      if (hit) {
        switch (_action.effect) with (UnitAction.Effect) {
          case damage:
            int prevHp = _target.hp;
            bool ignoreArmor = _action.hasSpecial(UnitAction.Special.pierce);
            effectAmount = _target.dealDamage(_action.power, ignoreArmor);
            break;
          case stun:
            _target.applyStun(_action.power);
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
          case slow:
            _target.applySlow(_action.power);
            break;
          default:
            assert(0, "no code to handle effect type");
        }
      }
      else {
        _target.dodgeAttack();
      }

      // show popup
      auto popupPos = cast(Vector2i) (_target.center - b.camera.area.topLeft);
      if (!hit) {
        int evd = _target.evade; // evade after attack
        // print previous and current evade
        b.gui.addElement(new BattlePopup(popupPos, BattlePopup.Type.miss, evd + 1, evd));
      }
      else {
        b.gui.addElement(new BattlePopup(popupPos, _action.effect, effectAmount));
      }

      b.states.setState(new Delay(delayDuration)); // pause briefly after applying effect
    }
  }

  private:
  Unit _target;
  const UnitAction _action;
}
