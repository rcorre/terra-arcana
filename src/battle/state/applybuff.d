module battle.state.applybuff;

import dau.all;
import model.all;
import gui.battlepopup;
import battle.battle;
import battle.pathfinder;
import battle.system.all;
import battle.state.delay;

private enum waitTime = 0.2f;

/// apply the result of a buff used on an ally
class ApplyBuff : State!Battle {
  this(const UnitAction action, Unit target) {
    _target = target;
    _action = action;
  }

  override { // TODO: show effect on status bar
    void enter(Battle b) {
      switch (_action.effect) with (UnitAction.Effect) {
        case heal:
          _target.restoreHealth(_action.power);
          break;
        case evade:
          _target.adjustEvade(_action.power);
          break;
        case armor:
          _target.adjustArmor(_action.power);
          break;
        default:
          assert(0, "no code to handle effect type");
      }

      // show popup
      auto popupPos = cast(Vector2i) (_target.center - b.camera.area.topLeft);
      b.gui.addElement(new BattlePopup(popupPos, _action.effect, _action.power));

      b.states.setState(new Delay); // pause briefly after applying buff
    }
  }

  private:
  Unit _target;
  const UnitAction _action;
}
