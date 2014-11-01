module battle.ai.moveoption;

import battle.battle;
import battle.ai.profile;
import battle.ai.option;
import battle.ai.advantage;
import model.all;

class MoveOption : AIOption {
  Unit unit()   { return _unit; }
  Tile target() { return _target; }

  this(Unit unit, Tile target, Unit[] enemyUnits) {
    this.unit = unit;
    this.target = target;
  }

  override float computeScore(Battle b, AIProfile profile) {
    float score = 0;
    foreach(enemy ; _enemyUnits) {
      float distFactor = 1.0f / target.distance(enemy.tile);
      score += getAdvantage(enemy, unit) * distFactor;
    }
    foreach(obelisk ; battle.obelisks) {
      float distFactor = 1.0f / target.distance(obelisk.row, obelisk.col);
      if (obelisk.team == profile
      score += profile.
    }
    return score * profile.mobility;
  }

  private:
  Unit   _unit;   /// unit to move
  Tile   _target; /// tile to move to
  Unit[] _enemyUnits;
}
