module battle.ai.unitai;

import std.array, std.algorithm;
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
    bool canMoveAndAttack = stayOnTile ? false : cmdPoints >= 2;
    final switch (goal.type) with (AIGoal.Type) {
      case attack:
        return bestAttackOption(goal.target, canMoveAndAttack);
      case aid:
        return bestAidOption(goal.target, canMoveAndAttack);
      case capture:
        return bestCaptureOption(goal.target);
    }
  }

  auto bestCaptureOption(Tile tile) {
    if (stayOnTile) { return null; }
    if (tile == _unit.tile) { 
      return null; // already on tile
    }
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
    if (stayOnTile) { return null; }
    AIDecision bestOption;
    foreach (tile ; _pathfinder.tilesInRange) {
      if (tile != _unit.tile && !canMove) { continue; }
      int apLeft = _unit.ap - _pathfinder.costTo(tile);
      foreach(num ; [1, 2]) {
        if (_unit.canUseActionFrom(num, target, tile, apLeft) && _unit.getAction(num).isAttack) {
          auto option = createAttackOption(num, target, tile);
          if (bestOption is null || option.score > bestOption.score) {
            bestOption = option;
          }
        }
      }
    }
    return bestOption;
  }

  auto bestAidOption(Tile target, bool canMove) {
    if (stayOnTile) { return null; }
    auto enemies = _battle.enemiesTo(_unit.team);
    AIDecision bestOption;
    foreach (tile ; _pathfinder.tilesInRange) {
      if (tile != _unit.tile && !canMove) { continue; }
      int apLeft = _unit.ap - _pathfinder.costTo(tile);
      foreach(num ; [1,2]) {
        if (_unit.canUseActionFrom(num, target, tile, apLeft) && !_unit.getAction(num).isAttack) {
          auto option = createBuffOption(num, target, tile, enemies);
          if (bestOption is null || option.score > bestOption.score) {
            bestOption = option;
          }
        }
      }
    }
    return bestOption;
  }

  private:
  Unit _unit;
  Pathfinder _pathfinder;
  TileMap _map;
  AIProfile _profile;
  Battle _battle;

  auto createAttackOption(int actNum, Tile target, Tile attackPosition) {
    auto path = _pathfinder.pathTo(attackPosition);
    auto tileScore = computeTilePriority(_battle, _profile, attackPosition, _unit);
    auto attackScore = attackScore(_unit, target, actNum, _profile, _map);
    auto score = average(tileScore, attackScore);
    return new ActDecison(_unit, path, target, actNum, score);
  } 

  auto createBuffOption(int actNum, Tile target, Tile buffPosition, Unit[] enemies) {
    auto path = _pathfinder.pathTo(buffPosition);
    auto tileScore = computeTilePriority(_battle, _profile, buffPosition, _unit);
    auto buffScore = buffScore(_unit, target, actNum, _profile, enemies);
    auto score = average(tileScore, buffScore);
    return new ActDecison(_unit, path, target, actNum, score);
  } 

  @property bool stayOnTile() {
    auto obelisk = cast(Obelisk) _unit.tile.feature;
    return obelisk !is null && obelisk.team != _unit.team;
  }
}
