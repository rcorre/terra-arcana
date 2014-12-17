module battle.ai.helpers;

import std.math, std.algorithm;
import dau.util.math;
import model.all;
import battle.battle;
import battle.ai.profile;

/// AI's determination of how useful each effect is
private enum effectFactor = [
  UnitAction.Effect.damage : 1.0,
  UnitAction.Effect.heal   : 1.0,
  UnitAction.Effect.toxin  : 0.7,
  UnitAction.Effect.slow   : 0.6,
  UnitAction.Effect.stun   : 0.6,
  UnitAction.Effect.evade  : 0.8,
  UnitAction.Effect.armor  : 0.8,
  UnitAction.Effect.transform  : 0.4
];

private enum wasteEvadeScore = 0.3; /// score for degrading the targets evasion

float attackScore(Unit attacker, Tile target, int actionNum, AIProfile profile) {
  auto defender = cast(Unit) target.entity;
  auto action = attacker.getAction(actionNum);
  return attackScore(attacker, defender, action, profile);
}

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

float buffScore(Unit actor, Tile target, int actNum, AIProfile profile,
    Unit[] enemies)
{
  auto receiver = cast(Unit) target.entity;
  auto action = actor.getAction(actNum);
  if (receiver is null) {
    return 0;
  }
  else if (action.effect == UnitAction.Effect.heal) {
    float hpFactor = (receiver.maxHp - receiver.hp) / cast(float) receiver.maxHp;
    return action.power * effectFactor[UnitAction.Effect.heal] * hpFactor;
  }
  else {
    int threatDistance = enemies.map!(x => x.tile.distance(receiver.tile)).minPos.front;
    float threatFactor = 1 - (threatDistance - 1) * 0.2;
    return action.power * effectFactor[action.effect] * threatFactor;
  }
}

float effectScore(const UnitAction action, Unit defender) {
  return (action.predictEffect(defender) * effectFactor[action.effect]) / defender.hp;
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

auto idealAttack(Unit attacker, Unit defender, AIProfile profile) {
  int idealAction = 0;
  float idealScore = 0;
  if (attacker.canUseAction(1, defender)) {
    idealAction = 1;
    idealScore = attackScore(attacker, defender, attacker.getAction(1), profile);
  }
  if (attacker.canUseAction(2, defender)) {
    if (attackScore(attacker, defender, attacker.getAction(1), profile) > idealScore) {
      idealAction = 2;
    }
  }

  return idealAction == 0 ? null : attacker.getAction(idealAction);
}

float computeTilePriority(Battle b, AIProfile profile, Tile tile, Unit unit) {
  float[] scores;
  float[] weights;
  foreach(enemy ; b.enemiesTo(unit.team)) {
    auto attack = idealAttack(unit, enemy, profile);
    if (attack !is null) {
      scores ~= attackScore(unit, enemy, attack, profile);
      weights ~= 1.0f;
    }
  }

  foreach(obelisk ; b.obelisks) {
    float distFactor = 1.0f / tile.distance(obelisk.row, obelisk.col);
    scores ~= ((obelisk.team == unit.team) ? profile.protectObelisk : profile.claimObelisk);
    weights ~= distFactor;
  }
  return scores.weightedAverage(weights) * profile.mobility;
}

float proximityScore(Tile src, Tile dest) {
  int dist = src.distance(dest);
  return 1.0f / (dist + 1.0f);
}
