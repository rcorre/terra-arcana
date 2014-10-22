module battle.pathfinder;

import std.container : RedBlackTree;
import std.algorithm;
import model.all;

private enum noParent = -1;

class Pathfinder {
  this(TileMap map, Unit unit) {
    _map = map;
    _unit = unit;
    djikstra();
    for(int i = 0; i < numTiles; ++i) {
      if (_dist[i] < _unit.ap) {
        auto tile = idxToTile(i);
        if (tile.entity is null) { // only include unoccupied tiles
          _tilesInRange ~= tile;
        }
      }
    }
  }

  @property auto tilesInRange() { return _tilesInRange[]; }

  private:
  TileMap _map;
  Unit    _unit;
  Tile[]  _tilesInRange;
  Node[]  _nodes;
  int[]   _dist;
  int[]   _prev;

  @property numTiles() { return _map.numRows * _map.numCols; }
  @property origin() { return _unit.tile; }

  int tileToIdx(Tile tile) {
    return tile.row * _map.numCols + tile.col;
  }

  Tile idxToTile(int i) {
    return _map.tileAt(i / _map.numCols, i % _map.numCols);
  }

  void djikstra() {
    _dist = new int[numTiles];
    _prev = new int[numTiles];
    bool[] scanned;
    _dist.fill(Tile.unreachable);
    _prev.fill(noParent);
    _dist[tileToIdx(origin)] = 0;
    auto queue = new RedBlackTree!(Node, "a.dist < b.dist");
    queue.insert(Node(origin, 0));

    while(!queue.empty) {
      auto node = queue.front;
      queue.removeFront;
      int nodeIdx = tileToIdx(node.tile);
      if (scanned[nodeIdx]) { continue; }
      scanned[nodeIdx] = true; // instead of updating priority
      foreach(neighbor ; _map.neighbors(node.tile)) {
        int neighborIdx = tileToIdx(neighbor);
        if (!scanned[neighborIdx]) {
          int alt = _dist[nodeIdx] + neighbor.moveCost;
          if (alt < _dist[neighborIdx]) {
            _prev[neighborIdx] = nodeIdx;
            _dist[neighborIdx] = alt;
            queue.insert(Node(neighbor, alt));
          }
        }
      }
    }
  }

  struct Node {
    this(Tile tile, int dist) {
      this.tile = tile;
      this.dist = dist;
    }

    Tile tile;
    int dist = Tile.unreachable;
  }
}
