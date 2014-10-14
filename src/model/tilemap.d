module model.tilemap;

import std.string;
import dau.geometry.all;
import dau.engine;
import dau.entity;
import dau.tool.tiled;
import model.tile;

class TileMap : Entity {
  this(string key) {
    auto path = "%s/%s.json".format(cast(string) Paths.mapDir, key);
    auto map = loadTiledMap(path);
    auto terrain = map.layerTileData("terrain");
    foreach(data ; terrain) {
      registerEntity(new Tile(data));
    }

    auto area = Rect2i(Vector2i.zero, Vector2i(map.width, map.height) * Tile.size);
    super(area, "map");
  }
}
