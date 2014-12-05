module battle.battle;

import std.range, std.algorithm, std.conv;
import dau.all;
import net.all;
import model.all;
import battle.state.pcturn;
import battle.state.playerturn;
import battle.state.networkturn;
import battle.state.checkunitdestruction;
import battle.system.all;
import battle.ai.all;
import gui.battlepanel;

private enum mapFormat = Paths.mapDir ~ "/%s.json";

class Battle : Scene!Battle {
  this(string mapName, Faction playerFaction, Faction pcFaction, NetworkClient client = null,
      bool isHost = false)
  {
    _client = client;
    if (client is null) {
      _players = [new Player(playerFaction, 1, true), new AIPlayer(pcFaction, 2, "balanced")];
    }
    else if (isHost) {
      _players = [new Player(playerFaction, 1, true), new Player(pcFaction, 2, false)];
    }
    else {
      _players = [new Player(pcFaction, 1, false), new Player(playerFaction, 2, true)];
    }
    System!Battle[] systems = [
      new TileHoverSystem(this),
          new BattleCameraSystem(this),
          new BattleNetworkSystem(this, client)
    ];
    Sprite[string] cursorSprites = [
      "inactive" : new Animation("gui/cursor", "inactive", Animation.Repeat.loop),
      "active"   : new Animation("gui/cursor", "active", Animation.Repeat.loop),
      "ally"     : new Animation("gui/cursor", "ally", Animation.Repeat.loop),
      "enemy"    : new Animation("gui/cursor", "enemy", Animation.Repeat.loop),
      "wait"    : new Animation("gui/cursor", "wait", Animation.Repeat.loop),
    ];
    super(systems, cursorSprites);
    _panel = new BattlePanel;
    gui.addElement(_panel);
    _turnCycle = cycle(_players);
    cursor.setSprite("inactive");

    auto mapData = loadTiledMap(mapFormat.format(mapName));
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

    playMusicTrack(playerFaction.themeSong, true);
    startNewTurn;
  }

package:
  TileMap map;

  @property {
    auto players() { return _players[]; }
    auto activePlayer() { return _activePlayer; }
    auto obelisks() { return entities.findEntities("obelisk").map!(x => cast(Obelisk) x); }
  }

  auto spawnPointsFor(int teamIdx) {
    return _spawnPoints.filter!(x => x.team == teamIdx)
      .filter!(x => x.tile.entity is null)
      .map!(x => x.tile);
  }

  auto spawnUnit(string key, Player player, Tile tile) {
    auto unit = new Unit(key, tile, player.teamIdx);
    entities.registerEntity(unit);
    player.registerUnit(unit);
    return unit;
  }

  void startNewTurn() {
    if (_activePlayer !is null) {
      _activePlayer.endTurn();
      states.popState(); // pop previous player's turn state
    }
    auto player = _turnCycle.front;
    _turnCycle.popFront;
    assert(states.empty, "extra states on stack when starting new turn");
    if (player.isLocal) {
      states.pushState(new PlayerTurn(player));
    }
    else if (_client is null) {
      states.pushState(new PCTurn(player));
    }
    else {
      states.pushState(new NetworkTurn(player));
    }
    _activePlayer = player;

    foreach(obelisk ; obelisks) {
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

  auto enemiesTo(int team) {
    Unit[] enemies;
    auto others = players.filter!(x => x.teamIdx != team);
    foreach(other ; others) {
      enemies ~= other.units;
    }
    return enemies;
  }

  private:
  BattlePanel _panel;
  Cycle!(Player[]) _turnCycle;
  Player _activePlayer;
  Player[] _players;
  SpawnPoint[] _spawnPoints;
  NetworkClient _client;

  class SpawnPoint {
    this(Tile tile, int team) {
      this.tile = tile;
      this.team = team;
    }
    Tile tile;
    int team;
  }
}
