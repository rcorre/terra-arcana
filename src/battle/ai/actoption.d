module battle.ai.actoption;

import std.conv, std.algorithm;
import battle.battle;
import battle.ai.profile;
import battle.ai.option;
import battle.ai.helpers;
import model.all;

/// option to perform a unit action
class ActOption : AIOption {
  this(Unit unit, Unit target, int actionNum) {
    _unit = unit;
    _target = target;
    _actionNum = actionNum;
  }

  @property {
    Unit unit()      { return _unit; }
    Unit target()    { return _target; }
    int  actionNum() { return _actionNum; }
  }

  override float computeScore(Battle b, AIProfile profile) {
    auto action = unit.getAction(actionNum);
    if (target.team != unit.team) {
      return attackScore(unit, target, action, profile);
    }
    else {
      return buffScore(unit, target, action, profile);
    }
  }

  private:
  Unit _unit;      /// unit to perform action with
  Unit _target;    /// tile to perform action to
  int  _actionNum; /// which action to perform
}
