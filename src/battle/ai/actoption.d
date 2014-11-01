module battle.ai.actoption;

import std.conv, std.algorithm;
import battle.battle;
import battle.ai.profile;
import battle.ai.option;
import model.all;

private enum {
  healFactor  = 1.0,
  poisonFactor = 0.7,
  slowFactor = 0.6,
  stunFactor = 0.6,
  wasteEvadeScore = 0.3 /// score for degrading the targets evasion
}

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
    float score = damageScore(unit, target, actionNum);
    int counter = target.firstUseableAction(unit);
    float counterPenalty = damageScore(target, unit, counter);
    return score - counterPenalty;
  }

  float buffScore() {
    auto buff = unit.getAction(actionNum);
    switch (buff.effect) with (UnitAction.Effect) {
      case heal:
        return buff.power * healFactor;
      default:
        assert(0, "cannot predict buff score for effect " ~ buff.effect.to!string);
    }
    assert(0);
  }

  float damageScore(Unit attacker, Unit defender, int attackNum) {
    if (attackNum == 0) { return 0; }
    auto action = attacker.getAction(attackNum);
    float score;
    bool ignoreArmor = action.hasSpecial(UnitAction.Special.pierce);
    bool ignoreEvade = action.hasSpecial(UnitAction.Special.precise);
    switch (action.effect) with (UnitAction.Effect) {
      case damage:
        score = action.power - (ignoreArmor) ? 0 : defender.armor;
        break;
      case toxin:
        score = action.power * poisonFactor;
        break;
      case slow:
        score = action.power * slowFactor;
        break;
      case stun:
        score = action.power * stunFactor;
        break;

      default:
        assert(0, "cannot predict damage score for effect " ~ action.effect.to!string);
    }

    if (ignoreEvade) {
      score *= action.hits;
    }
    else {
      int numHits = max(0, action.hits - defender.evade);
      int numMisses = action.hits - numHits;
      score *= numHits;
      score += numMisses * wasteEvadeScore;
    }

    return score;
  }

  private:
  Unit _unit;      /// unit to perform action with
  Unit _target;    /// tile to perform action to
  int  _actionNum; /// which action to perform
}
