module battle.battle;

import std.range, std.algorithm, std.conv;
import dau.all;
import model.all;
import battle.state.playerturn;
import battle.state.pcturn;
import battle.system.all;
import gui.battlepanel;

private enum {
  cameraScrollSpeed = 12,
  baseCommandPoints = 6  // TODO: set based on map
}

class Battle : Scene!Battle {
  //this(Player[] players) { // TODO: load players from previous state
  this() {
    _players = [
      new Player(getFaction("Human"), 1, true,  baseCommandPoints),
      new Player(getFaction("Gaia"),  2, false, baseCommandPoints)
    ];
    System!Battle[] systems = [
      new TileHoverSystem(this),
      new BattleCameraSystem(this),
    ];
    super(systems);
    _battlePanel = new BattlePanel;
    gui.addElement(_battlePanel);
    _turnCycle = cycle(_players);
    startNewTurn;
  }

  override {
    void enter() {
      auto mapPath = "%s/%s.json".format(cast(string) Paths.mapDir, "test");
      auto mapData = loadTiledMap(mapPath);
      map = new TileMap(mapData, entities);
      entities.registerEntity(map);
      foreach(obj ; mapData.layerTileData("spawn")) {
        _spawnPoints ~= new SpawnPoint(map.tileAt(obj.row, obj.col), obj.objectType.to!int);
      }
      camera.bounds = Rect2f(Vector2f.zero, cast(Vector2f) map.totalSize);
      spawnUnit("assault", _players[0], map.tileAt(3,3));
      spawnUnit("hellblossom", _players[1], map.tileAt(3,5));
    }

    void update(float time) {
      super.update(time);
    }
  }

package:
  TileMap map;

  @property auto players() { return _players[]; }
  @property void lockLeftUnitInfo(bool val) {
    _lockLeftUnitInfo = val;
    displayUnitInfo(null);
  }

  auto unitInfoFor(Unit unit) {
    if (_battlePanel.leftUnitInfo.unit == unit) {
      return _battlePanel.leftUnitInfo;
    }
    else if (_battlePanel.rightUnitInfo.unit == unit) {
      return _battlePanel.rightUnitInfo;
    }
    else {
      assert(0, "no unit info gui found for unit " ~ unit.name);
    }
  }

  auto spawnPointsFor(int teamIdx) {
    return _spawnPoints.filter!(x => x.team == teamIdx).map!(x => x.tile);
  }

  void spawnUnit(string key, Player player, Tile tile) {
    auto unit = new Unit(key, tile, player.teamIdx);
    entities.registerEntity(unit);
    player.registerUnit(unit);
  }

  void displayUnitInfo(Unit unit) {
    if (_lockLeftUnitInfo) {
      _battlePanel.setRightUnitInfo(unit);
    }
    else {
      _battlePanel.setLeftUnitInfo(unit);
    }
  }

  void startNewTurn() {
    if (_activePlayer !is null) {
      foreach(unit ; _activePlayer.units) {
        unit.endTurn();
      }
      states.popState(); // pop previous player's turn state
    }
    auto player = _turnCycle.front;
    _turnCycle.popFront;
    assert(states.empty, "extra states on stack when starting new turn");
    states.pushState(player.isHuman ? new PlayerTurn(player) : new PCTurn(player));
    foreach(unit ; player.units) {
      unit.startTurn();
    }
    _activePlayer = player;
    updateBattlePanel();
  }

  void updateBattlePanel() {
    _battlePanel.setCommandCounter(_activePlayer.commandPoints, _activePlayer.maxCommandPoints);
    _battlePanel.setManaCounter(_activePlayer.mana);
  }

  private:
  BattlePanel _battlePanel;
  Cycle!(Player[]) _turnCycle;
  Player _activePlayer;
  Player[] _players;
  bool _lockLeftUnitInfo;
  SpawnPoint[] _spawnPoints;

  class SpawnPoint {
    this(Tile tile, int team) {
      this.tile = tile;
      this.team = team;
    }
    Tile tile;
    int team;
  }
}
