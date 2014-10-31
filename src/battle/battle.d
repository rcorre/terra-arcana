module battle.battle;

import std.range, std.algorithm, std.conv;
import dau.all;
import model.all;
import battle.state.playerturn;
import battle.state.pcturn;
import battle.state.checkunitdestruction;
import battle.system.all;
import gui.battlepanel;

private enum {
  cameraScrollSpeed = 12,
}

class Battle : Scene!Battle {
  //this(Player[] players) { // TODO: load players from previous state
  this() {
    _players = [
      new Player(getFaction("Federation"), 1, true),
      new Player(getFaction("Gaia"),  2, false)
    ];
    System!Battle[] systems = [
      new TileHoverSystem(this),
      new BattleCameraSystem(this),
    ];
    super(systems);
    _panel = new BattlePanel;
    gui.addElement(_panel);
    _turnCycle = cycle(_players);
  }

  override {
    void enter() {
      auto mapPath = "%s/%s.json".format(cast(string) Paths.mapDir, "test");
      auto mapData = loadTiledMap(mapPath);
      map = new TileMap(mapData, entities);
      entities.registerEntity(map);
      foreach(obj ; mapData.layerTileData("feature")) {
        int team = obj.objectType.to!int;
        switch(obj.objectName) {
          case "spawn":
            _spawnPoints ~= new SpawnPoint(map.tileAt(obj.row, obj.col), team);
            break;
          case "obelisk":
            auto pos = map.tileAt(obj.row, obj.col).center;
            auto obelisk = new Obelisk(pos, obj.row, obj.col);
            entities.registerEntity(obelisk);
            if (team != 0) {
              captureObelisk(obelisk, team);
            }
            break;
          default:
            assert(0, "invalid object named " ~ obj.objectName);
        }
      }
      camera.area = Rect2f(0, 0, Settings.screenW, Settings.screenH - _panel.area.height);
      camera.bounds = Rect2f(Vector2f.zero, cast(Vector2f) map.totalSize);
      spawnUnit("assault", _players[0], map.tileAt(3,3));
      spawnUnit("wyvern", _players[1], map.tileAt(3,5));
      spawnUnit("treant", _players[1], map.tileAt(5,3));
      startNewTurn;
    }

    void update(float time) {
      super.update(time);
    }
  }

package:
  TileMap map;

  @property auto players() { return _players[]; }
  @property auto activePlayer() { return _activePlayer; }
  @property void lockLeftUnitInfo(bool val) {
    _lockLeftUnitInfo = val;
    displayUnitInfo(null);
  }

  auto unitInfoFor(Unit unit) {
    if (_panel.leftUnitInfo.unit == unit) {
      return _panel.leftUnitInfo;
    }
    else if (_panel.rightUnitInfo.unit == unit) {
      return _panel.rightUnitInfo;
    }
    else {
      assert(0, "no unit info gui found for unit " ~ unit.name);
    }
  }

  auto spawnPointsFor(int teamIdx) {
    return _spawnPoints.filter!(x => x.team == teamIdx).map!(x => x.tile);
  }

  auto spawnUnit(string key, Player player, Tile tile) {
    auto unit = new Unit(key, tile, player.teamIdx);
    entities.registerEntity(unit);
    player.registerUnit(unit);
    return unit;
  }

  void displayUnitInfo(Unit unit) {
    if (_lockLeftUnitInfo) {
      _panel.setRightUnitInfo(unit);
    }
    else {
      _panel.setLeftUnitInfo(unit);
    }
  }

  void startNewTurn() {
    if (_activePlayer !is null) {
      _activePlayer.endTurn();
      states.popState(); // pop previous player's turn state
    }
    auto player = _turnCycle.front;
    _turnCycle.popFront;
    assert(states.empty, "extra states on stack when starting new turn");
    states.pushState(player.isHuman ? new PlayerTurn(player) : new PCTurn(player));
    _activePlayer = player;

    foreach(obelisk ; entities.findEntities("obelisk").map!(x => cast(Obelisk) x)) {
      auto tile = map.tileAt(obelisk.row, obelisk.col);
      auto unit = cast(Unit) tile.entity;
      if (unit !is null && unit.team != obelisk.team) { // switch obelisk team
        captureObelisk(obelisk, unit.team);
      }
    }

    player.beginTurn();
    foreach(unit ; player.units) { // check if any units were killed by poison
      states.pushState(new CheckUnitDestruction(unit));
    }
    updateBattlePanel();
  }

  void updateBattlePanel() {
    _panel.setCommandCounter(_activePlayer.commandPoints, _activePlayer.maxCommandPoints);
    _panel.setManaCounter(_activePlayer.mana);
  }

  void captureObelisk(Obelisk obelisk, int team) {
    auto player = playerByTeam(team);
    if (obelisk.team != 0) { // was not neutral before
      auto prevOwner = _players.find!(x => x.teamIdx == obelisk.team).front;
      prevOwner.maxCommandPoints -= obelisk.commandBonus;
    }
    obelisk.setTeam(player.teamIdx, player.faction.name);
    player.maxCommandPoints += obelisk.commandBonus;
  }

  void destroyUnit(Unit unit) {
    auto player = playerByTeam(unit.team);
    player.destroyUnit(unit);
    entities.removeEntity(unit);
  }

  auto playerByTeam(int team) {
    auto r = _players.find!(x => x.teamIdx == team);
    assert(!r.empty, "no player with teamIdx = %d".format(team));
    return r.front;
  }

  private:
  BattlePanel _panel;
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
