module battle.ai.moveoption;

import battle.battle;
import battle.pathfinder;
import battle.ai.profile;
import battle.ai.option;
import battle.ai.advantage;
import model.all;

class MoveOption : AIOption {
  @property {
    auto unit() { return _unit; }
    auto path() { return _pathFinder.pathTo(_target); }
  }

  this(Unit unit, Tile target, Unit[] enemyUnits, int team, Pathfinder pathFinder) {
    _unit = unit;
    _target = target;
    _enemyUnits = enemyUnits;
    _pathFinder = pathFinder;
  }

  override float computeScore(Battle b, AIProfile profile) {
    float score = 0;
    foreach(enemy ; _enemyUnits) {
      float distFactor = 1.0f / _target.distance(enemy.tile);
      score += getAdvantage(enemy.key, unit.key) * distFactor;
    }
    foreach(obelisk ; b.obelisks) {
      float distFactor = 1.0f / _target.distance(obelisk.row, obelisk.col);
      if (obelisk.team == team) {
        score += profile.protectObelisk;
      }
      else if (obelisk.team == 0) {
        score += profile.claimObelisk;
      }
      else {
        score += profile.stealObelisk;
      }
    }
    return score * profile.mobility;
  }

  private:
  Unit   _unit;   /// unit to move
  Tile   _target; /// tile to move to
  Unit[] _enemyUnits;
  Pathfinder _pathFinder;
  int team;
}
