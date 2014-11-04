module battle.ai.helpers;

import dau.util.math;
import model.all;
import battle.battle;
import battle.ai.profile;

/// AI's determination of how useful each effect is
private enum effectFactor = [
  UnitAction.Effect.damage : 1.0,
  UnitAction.Effect.heal   : 1.0,
  UnitAction.Effect.toxin  : 0.7,
  UnitAction.Effect.slow   : 0.8,
  UnitAction.Effect.stun   : 0.8
];

private enum wasteEvadeScore = 0.3; /// score for degrading the targets evasion

float attackScore(Unit attacker, Unit defender, const UnitAction action, AIProfile profile) {
  float score = action.effectScore(defender) ;
  if (!action.willDisableDefender(defender)) {
    int counterNum = defender.firstUseableAction(attacker);
    if (counterNum != 0) {
      auto counter = defender.getAction(counterNum);
      score -= counter.effectScore(attacker) * profile.avoidCounter;
    }
  }
  return score * profile.agression;
}

float buffScore(Unit actor, Unit receiver, const UnitAction action, AIProfile profile) {
  return action.power * effectFactor[action.effect]; // TODO compare against unit hp
}

float effectScore(const UnitAction action, Unit defender) {
  return max((action.predictEffect(defender) * effectFactor[action.effect]) / defender.hp, 1);
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

float computeTilePriority(Battle b, AIProfile profile, Tile tile, int team) {
  float[] scores;
  /*
     foreach(enemy ; _enemyUnits) {
     float distFactor = 1.0f / _target.distance(enemy.tile);
     score += getAdvantage(enemy.key, unit.key) * distFactor;
     }
   */

  foreach(obelisk ; b.obelisks) {
    float distFactor = 1.0f / tile.distance(obelisk.row, obelisk.col);
    scores ~= ((obelisk.team == team) ? profile.protectObelisk : profile.claimObelisk) * distFactor;
  }
  return scores.average * profile.mobility;
}
