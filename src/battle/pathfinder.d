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
      if (_dist[i] <= _unit.ap) {
        auto tile = idxToTile(i);
        if (tile.entity is null) { // only include unoccupied tiles
          _tilesInRange ~= tile;
        }
      }
    }
  }

  @property auto tilesInRange() { return _tilesInRange[]; }

  auto pathTo(Tile tile) {
    int idx = tileToIdx(tile);
    int startIdx = tileToIdx(origin);
    if (_dist[idx] > _unit.ap || tile.entity !is null) {
      return null;
    }
    Tile[] path;
    while(idx != startIdx) {
      path ~= idxToTile(idx);
      idx = _prev[idx];
    }
    return path;
  }

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

  int computeMoveCost(Tile tile) {
    auto other = cast(Unit) tile.entity;
    if (other !is null && other.team != _unit.team) {
      return Tile.unreachable;
    }
    return tile.moveCost;
  }

  void djikstra() {
    _dist = new int[numTiles];
    _prev = new int[numTiles];
    bool[] scanned = new bool[numTiles];
    _dist.fill(Tile.unreachable);
    _prev.fill(noParent);
    _dist[tileToIdx(origin)] = 0;
    auto queue = new RedBlackTree!(Node, "a.dist < b.dist", true); // true: allowDuplicates
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
          int alt = _dist[nodeIdx] + computeMoveCost(neighbor);
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
