module model.tile;

import std.conv;
import std.math : abs;
import dau.entity;
import dau.geometry.all;
import dau.graphics.all;
import dau.tool.tiled;

class Tile : Entity {
  enum {
    size = 32,
    unreachable = 99
  }

  const {
    string name;
    int row, col;
    int cover;
    int moveCost;
  }

  Entity entity;  /// a unit or a wall
  Entity feature; /// an obelisk, mana pool, or spawn point
  Entity trap;    /// a trap

  this(TileData data) {
    auto pos = Vector2i(data.col, data.row) * size + Vector2i(size, size) / 2;
    auto sprite = new Sprite(getTexture(data.tilesetName), data.tilesetIdx);
    super(pos, sprite, "tile");
    row = data.row;
    col = data.col;
    name = data.properties.get("name", "ground");
    cover = data.properties.get("cover", "0").to!int;
    moveCost = data.properties.get("moveCost", "1").to!int;
  }

  int distance(Tile other) {
    return distance(other.row, other.col);
  }

  int distance(int otherRow, int otherCol) {
    return abs(row - otherRow) + abs(col - otherCol);
  }
}
