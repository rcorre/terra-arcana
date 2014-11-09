module battle.ai.unitai;

import std.array;
import dau.util.range;
import model.all;
import battle.battle;
import battle.pathfinder;
import battle.ai.decision;
import battle.ai.goal;
import battle.ai.helpers;

struct UnitAI {
  this(Unit unit, Battle battle) {
    _unit = unit;
    _pathfinder = new Pathfinder(battle.map, unit);
    _map = battle.map;
  }

  auto bestSolutionTo(AIGoal goal) {
    final switch (goal.type) with (AIGoal.Type) {
      case attack:
        return bestAttackOption(goal.target);
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

  auto bestAttackOption(Tile target) {
    AIDecision[] options;
    foreach (tile ; _pathfinder.tilesInRange) {
      int apLeft = _unit.ap - _pathfinder.costTo(tile);
      int act = _unit.firstUseableActionFrom(target, tile, apLeft);
      if (act != 0) {
        auto path = _pathfinder.pathTo(tile);
        // TODO : score using helpers
        options ~= new ActDecison(_unit, path, target, act, 1.0f);
      }
    }
    return options.frontOr(null);
  }

  private:
  Unit _unit;
  Pathfinder _pathfinder;
  TileMap _map;
}
