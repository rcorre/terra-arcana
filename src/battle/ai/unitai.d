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

  private:
  Unit _unit;
  Pathfinder _pathfinder;
  TileMap _map;

  float proximityScore(Tile src, Tile dest) {
    int dist = src.distance(dest);
    return 1.0f / (dist + 1.0f);
  }
}
