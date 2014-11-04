module battle.ai.moveoption;

import dau.util.math;
import battle.battle;
import battle.pathfinder;
import battle.ai.profile;
import battle.ai.helpers;
import battle.ai.option;
import model.all;

class MoveOption : AIOption {
  @property {
    auto unit() { return _unit; }
    auto path() { return _pathFinder.pathTo(_target); }
  }

  this(Unit unit, Tile target, Unit[] enemyUnits, int team, Pathfinder pathFinder, float current) {
    _unit = unit;
    _target = target;
    _enemyUnits = enemyUnits;
    _pathFinder = pathFinder;
    _team = team;
    _currentTilePriority = current; // current tile priority
  }

  override float computeScore(Battle b, AIProfile profile) {
    return computeTilePriority(b, profile, _target, _team) - _currentTilePriority;
  }

  private:
  Unit   _unit;   /// unit to move
  Tile   _target; /// tile to move to
  Unit[] _enemyUnits;
  Pathfinder _pathFinder;
  int _team;
  float _currentTilePriority;
}
