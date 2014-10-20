module model.tile;

import std.conv;
import dau.entity;
import dau.geometry.all;
import dau.graphics.all;
import dau.tool.tiled;

class Tile : Entity {
  enum size = 32;

  this(TileData data) {
    auto pos = Vector2i(data.col, data.row) * size + Vector2i(size, size) / 2;
    auto sprite = new Sprite(getTexture(data.tilesetName), data.tilesetIdx);
    super(pos, sprite, "tile");
    row = data.row;
    col = data.col;
    name = data.properties.get("name", "ground");
    cover = data.properties.get("cover", "0").to!int;
    impassable = data.properties.get("impassable", "false").to!bool;
  }

  const {
    string name;
    int row, col;
    int cover;
    bool impassable;
  }
  Entity entity;
}
