module battle.pathfinder;

import std.array, std.range, std.algorithm;
import std.container : RedBlackTree;
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

  auto costTo(Tile tile) {
    return pathTo(tile).map!(x => _unit.computeMoveCost(x)).sum;
  }

  /// return best path towards tile, clamped at moveRange
  Tile[] pathToward(Tile end) {
    auto fullPath = aStar(_unit.tile, end);
    if (!fullPath) { return null; } // not reachable

    Tile[] path;
    int cost = 0;
    // skip start as it will be seen as occupied
    foreach(tile ; fullPath.drop(1)) {
      cost += _unit.computeMoveCost(tile);
      if (cost <= _unit.ap) {
        path ~= tile;
      }
    }
    // strip occupied tiles from back
    while (!path.empty && path.back.entity !is null) {
      path.popBack();
    }

    return path.reverse;
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
          int alt = _dist[nodeIdx] + _unit.computeMoveCost(neighbor);
          if (alt < _dist[neighborIdx]) {
            _prev[neighborIdx] = nodeIdx;
            _dist[neighborIdx] = alt;
            queue.insert(Node(neighbor, alt));
          }
        }
      }
    }
  }

  /// use to find a route between a single pair of tiles
  Tile[] aStar(Tile startTile, Tile endTile) {
    int start = tileToIdx(startTile);
    int goal  = tileToIdx(endTile);

    int[] closedset;
    int[] openset = [start];
    int[int] parent;
    int[] gscore = new int[numTiles];
    int[] fscore = new int[numTiles];

    gscore[start] = 0;
    fscore[start] = 0;

    while(!openset.empty) {
      openset.sort!((a,b) => fscore[a] < fscore[b]);
      auto current = openset.front;

      if (current == goal) {
        return reconstructPath(parent, goal);
      }

      openset.popFront;
      closedset ~= current;

      foreach(tile ; _map.neighbors(idxToTile(current))) {
        auto neighbor = tileToIdx(tile);
        if (closedset.canFind(neighbor)) { continue; }
        auto tentative_gscore = gscore[current] + _unit.computeMoveCost(tile);

        if (!openset.canFind(neighbor) || tentative_gscore < gscore[neighbor]) {
          parent[neighbor] = current;
          gscore[neighbor] = tentative_gscore;
          fscore[neighbor] = gscore[neighbor] + manhattan(neighbor, goal);
          if (!openset.canFind(neighbor)) {
            openset ~= neighbor;
          }
        }
      }
    }

    return null;
  }

  int manhattan(int start, int end) {
    return abs(idxToRow(start) - idxToRow(end)) + abs(idxToCol(start) - idxToCol(end));
  }

  int idxToRow(int idx) {
    return idx / _map.numCols;
  }

  int idxToCol(int idx) {
    return idx % _map.numCols;
  }

  Tile[] reconstructPath(int[int] parents, int current) {
    Tile[] path;
    if (current in parents) {
      path = reconstructPath(parents, parents[current]);
      return path ~ idxToTile(current);
    }
    return [idxToTile(current)];
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
