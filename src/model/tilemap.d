module model.tilemap;

import std.algorithm, std.string, std.math, std.file, std.path;
import dau.all;
import model.tile;

class TileMap : Entity {
  const {
    int numRows, numCols;
  }

  this(MapData map, EntityManager entities) {
    numCols = map.width;
    numRows = map.height;
    auto terrain = map.layerTileData("terrain");
    _tiles = new Tile[][numRows];
    foreach(data ; terrain) {
      auto tile = new Tile(data);
      entities.registerEntity(tile);
      _tiles[tile.row] ~= tile;
    }

    auto area = Rect2i(Vector2i.zero, Vector2i(map.width, map.height) * Tile.size);
    super(area, "map");
  }

  @property {
    auto totalSize() { return Vector2i(numCols, numRows) * Tile.size; }
  }

  auto tileAt(int row, int col) {
    return (row < 0 || col < 0 || row >= numRows || col >= numCols) ? null : _tiles[row][col];
  }

  auto tileAt(Vector2i pos) {
    int row = pos.y / Tile.size;
    int col = pos.x / Tile.size;
    return tileAt(row, col);
  }

  /// return tiles adjacent to tile
  auto neighbors(Tile tile) {
    Tile[] neighbors;
    int row = tile.row;
    int col = tile.col;
    if (row > 0)           { neighbors ~= tileAt(row - 1, col); }
    if (col > 0)           { neighbors ~= tileAt(row, col - 1); }
    if (row < numRows - 1) { neighbors ~= tileAt(row + 1, col); }
    if (col < numCols - 1) { neighbors ~= tileAt(row, col + 1); }
    return neighbors;
  }

  auto tilesInRange(Tile center, int minRange, int maxRange) {
    Tile[] tiles;
    for (int row = center.row - maxRange ; row <= center.row + maxRange ; ++row) {
      for (int col = center.col - maxRange ; col <= center.col + maxRange ; ++col) {
        auto tile = tileAt(row, col);
        auto dist = abs(row - center.row) + abs(col - center.col);
        if (tile !is null && dist >= minRange && dist <= maxRange) {
          tiles ~= tile;
        }
      }
    }
    return tiles;
  }

  private:
  Tile[][] _tiles;
}

auto allMaps() {
  return _maps.values;
}

auto fetchMap(string key) {
  assert(key in _maps, "no map matches key " ~ key);
  return _maps[key];
}

auto mapKey(MapData data) {
  foreach(key, val ; _maps) {
    if (val == data) {
      return key;
    }
  }
  assert(0, "no key found for map data");
}

private:
MapData[string] _maps;

static this() {
  auto load = {
    foreach(entry ; Paths.mapDir.dirEntries(SpanMode.depth)) {
      auto key = entry.baseName(".json");
      _maps[key] = loadTiledMap(entry);
    }
  };
  onInit(load);
}
