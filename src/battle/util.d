module battle.util;

import std.algorithm;
import model.all;

auto tilesAffected(TileMap map, Tile target, Unit actor, const UnitAction action) {
  switch (action.target) with (UnitAction.Target) {
    case burst:
      return target ~ map.neighbors(target);
    case line:
      auto start = actor.tile;
      int rowDiff = target.row - start.row;
      int colDiff = target.col - start.col;
      if (rowDiff != 0) {
        return [target, map.tileAt(target.row + rowDiff, target.col)];
      }
      else if (colDiff != 0) {
        return [target, map.tileAt(target.row, target.col + colDiff)];
      }
      else {
        return [target];
      }
    default:
      return [target];
  }
}

auto unitsAffected(TileMap map, Tile target, Unit actor, const UnitAction action) {
  return tilesAffected(map, target, actor, action)
    .map!(x => cast(Unit) x.entity)
    .filter!(x => x!is null);
}
