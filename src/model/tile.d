module model.tile;

import dau.entity;
import dau.graphics.all;
import dau.tool.tiled;

class Tile : Entity {
  this(TileData data) {
  }

  const {
    int row, col;
    int cover;
    bool impassable;
  }
}
