module battle.ai.actoption;

import std.conv, std.algorithm;
import battle.battle;
import battle.ai.profile;
import battle.ai.option;
import model.all;

/// AI's determination of how useful each effect is
private enum effectFactor = [
  UnitAction.Effect.damage : 1.0,
  UnitAction.Effect.heal   : 1.0,
  UnitAction.Effect.toxin  : 0.7,
  UnitAction.Effect.slow   : 0.8,
  UnitAction.Effect.stun   : 0.8
];

private enum wasteEvadeScore = 0.3; /// score for degrading the targets evasion

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
    if (target.team != unit.team) {
      return attackScore() * profile.agression;
    }
    else {
      return buffScore();
    }
  }

  private:
  float attackScore() {
    auto action = unit.getAction(_actionNum);
    float score = action.effectScore(_target);
    if (!action.willDisableDefender(_target)) {
      int counterNum = _target.firstUseableAction(_unit);
      if (counterNum != 0) {
        auto counter = _target.getAction(counterNum);
        score -= counter.predictEffect(_unit);
      }
    }
    return score;
  }

  float buffScore() {
    auto buff = unit.getAction(actionNum);
    return buff.power * effectFactor[buff.effect];
  }

  Unit _unit;      /// unit to perform action with
  Unit _target;    /// tile to perform action to
  int  _actionNum; /// which action to perform
}

// calculation helpers
private:
float effectScore(const UnitAction action, Unit defender) {
  return action.predictEffect(defender) * effectFactor[action.effect];
}

int predictNumHits(const UnitAction action, Unit defender) {
  if (action.hasSpecial(UnitAction.Special.precise)) {
    return action.hits;
  }
  else {
    return max(0, action.hits - defender.evade);
  }
}

int predictEffect(const UnitAction action, Unit defender) {
  bool pierce = action.hasSpecial(UnitAction.Special.pierce);
  int power = action.power;
  if ((action.effect == UnitAction.effect.damage) && !pierce) {
    power = max(0, power - defender.armor);
  }
  return power * predictNumHits(action, defender);
}

/// return true if the attack will prevent a counter attack
bool willDisableDefender(const UnitAction action, Unit defender) {
  switch (action.effect) with (UnitAction.Effect) {
    case stun:
      return true;
    case damage:
      return predictEffect(action, defender) >= defender.hp;
    default:
      return false;
  }
}
