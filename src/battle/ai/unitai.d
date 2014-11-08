module battle.ai.unitai;

import std.array;
import model.all;
import battle.battle;
import battle.pathfinder;
import battle.ai.decision;

struct UnitAI {
  this(Unit unit, Battle battle) {
    _unit = unit;
    _pathfinder = new Pathfinder(battle.map, unit);
    _map = battle.map;
  }

  auto captureOption(Obelisk obelisk) {
    auto tile = _map.tileAt(obelisk.row, obelisk.col);
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

  auto attackOptions(Unit enemy) {
    AIDecision[] options;
    auto target = enemy.tile;
    foreach (tile ; _pathfinder.tilesInRange) {
      int act = _unit.firstUseableActionFrom(target, tile);
      if (act != 0) {
        auto path = _pathfinder.pathTo(tile);
        // TODO : score using helpers
        options ~= new ActDecison(_unit, path, target, act, 1.0f);
      }
    }
    return options;
  }

  private:
  Unit _unit;
  Pathfinder _pathfinder;
  TileMap _map;

  float proximityScore(Tile src, Tile dest) {
    int dist = src.distance(dest);
    return 1.0f / (dist + 1.0f);
  }
}
