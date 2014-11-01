module battle.ai.actoption;

import battle.battle;
import battle.ai.profile;
import battle.ai.option;
import model.all;

/// option to perform a unit action
class ActOption : AIOption {
  const Unit unit;   /// unit to perform action with
  const Unit target; /// tile to perform action to
  const int actionNum; /// which action to perform

  this(Unit unit, Unit target, int actionNum) {
    this.unit = unit;
    this.target = target;
    this.actionNum = actionNum;
  }

  override float computeScore(Battle b, AIProfile profile) {
    float score = profile.attack;
    return score;
  }
}
