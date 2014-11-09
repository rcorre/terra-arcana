module battle.ai.unitai;

import std.array;
import dau.util.all;
import model.all;
import battle.battle;
import battle.pathfinder;
import battle.ai.decision;
import battle.ai.goal;
import battle.ai.helpers;
import battle.ai.profile;

struct UnitAI {
  this(Unit unit, Battle battle, AIProfile profile) {
    _unit = unit;
    _pathfinder = new Pathfinder(battle.map, unit);
    _battle = battle;
    _map = battle.map;
    _profile = profile;
  }

  auto bestSolutionTo(AIGoal goal, int cmdPoints) {
    bool canMoveAndAttack = cmdPoints >= 2;
    final switch (goal.type) with (AIGoal.Type) {
      case attack:
        return bestAttackOption(goal.target, canMoveAndAttack);
      case aid:
        return null;
      case capture:
        return bestCaptureOption(goal.target);
    }
  }

  auto bestCaptureOption(Tile tile) {
    auto path = _pathfinder.pathTo(tile);
    if (path is null) {
      path = _pathfinder.pathToward(tile);
    }
    if (path is null || path.empty) {
      return null;
    }
    float score = proximityScore(path.front, tile);
    return new MoveDecison(_unit, path, score);
  }

  auto bestAttackOption(Tile target, bool canMove) {
    AIDecision[] options;
    foreach (tile ; _pathfinder.tilesInRange) {
      if (tile != _unit.tile && !canMove) { continue; }
      int apLeft = _unit.ap - _pathfinder.costTo(tile);
      int act = _unit.firstUseableActionFrom(target, tile, apLeft);
      if (act != 0) {
        auto path = _pathfinder.pathTo(tile);
        // TODO : score using helpers
        auto tileScore = computeTilePriority(_battle, _profile, tile, _unit);
        auto attackScore = attackScore(_unit, target, act, _profile);
        auto score = average(tileScore, attackScore);
        options ~= new ActDecison(_unit, path, target, act, score);
      }
    }
    return options.frontOr(null);
  }

  private:
  Unit _unit;
  Pathfinder _pathfinder;
  TileMap _map;
  AIProfile _profile;
  Battle _battle;
}
