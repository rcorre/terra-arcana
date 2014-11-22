module battle.util;

import std.algorithm;
import model.all;

auto tilesAffected(TileMap map, Tile target, Unit actor, const UnitAction action) {
  switch (action.target) with (UnitAction.Target) {
    case burst:
      return target ~ map.neighbors(target);
    case line:
      assert(0);
    default:
      return [target];
  }
}

auto unitsAffected(TileMap map, Tile target, Unit actor, const UnitAction action) {
  return tilesAffected(map, target, actor, action)
    .map!(x => cast(Unit) x.entity)
    .filter!(x => x!is null);
}
