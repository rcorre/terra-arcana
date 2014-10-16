module model.tilemap;

import std.string;
import dau.geometry.all;
import dau.engine;
import dau.entity;
import dau.tool.tiled;
import model.tile;

class TileMap : Entity {
  const {
    int numRows, numCols;
  }

  this(string key) {
    auto path = "%s/%s.json".format(cast(string) Paths.mapDir, key);
    auto map = loadTiledMap(path);
    numCols = map.width;
    numRows = map.height;
    auto terrain = map.layerTileData("terrain");
    _tiles = new Tile[][numRows];
    foreach(data ; terrain) {
      auto tile = new Tile(data);
      registerEntity(tile);
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

  private:
  Tile[][] _tiles;
}
