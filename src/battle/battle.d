module battle.battle;

import core.memory;
import std.range, std.algorithm, std.conv, std.typecons;
import dau.all;
import net.all;
import model.all;
import battle.state.pcturn;
import battle.state.battleover;
import battle.state.playerturn;
import battle.state.networkturn;
import battle.state.checkunitdestruction;
import battle.system.all;
import battle.ai.all;
import gui.battlepanel;
import gui.battlepopup;

private enum mapFormat = Paths.mapDir ~ "/%s.json";

class Battle : Scene!Battle {
  this(MapLayout layout, Faction playerFaction, Faction pcFaction, NetworkClient client = null,
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
      new InputHintSystem(this),
      new BattleCameraSystem(this),
      new UndoMoveSystem(this),
      new BattleNetworkSystem(this, client)
    ];
    Sprite[string] cursorSprites = [
      "inactive" : new Animation("gui/cursor", "inactive", Animation.Repeat.loop),
      "active"   : new Animation("gui/cursor", "active", Animation.Repeat.loop),
      "ally"     : new Animation("gui/cursor", "ally", Animation.Repeat.loop),
      "enemy"    : new Animation("gui/cursor", "enemy", Animation.Repeat.loop),
      "wait"     : new Animation("gui/cursor", "wait", Animation.Repeat.loop),
    ];
    super(systems, cursorSprites);
    _panel = new BattlePanel;
    gui.addElement(_panel);
    _turnCycle = cycle(_players);
    cursor.setSprite("inactive");

    map = new TileMap(layout.mapData, entities);
    entities.registerEntity(map);
    foreach(obj ; layout.objectData) {
      int team = obj.objectType.to!int;
      switch(obj.objectName) {
        case "spawn":
          _spawnPoints ~= new SpawnPoint(map.tileAt(obj.row, obj.col), team);
          break;
        case "obelisk":
          auto tile = map.tileAt(obj.row, obj.col);
          auto obelisk = new Obelisk(tile.center, obj.row, obj.col);
          tile.feature = obelisk;
          entities.registerEntity(obelisk);
          if (team != 0) {
            captureObelisk(obelisk, team);
          }
          break;
        default:
          assert(0, "invalid object named " ~ obj.objectName);
      }
    }

    preloadTextures("content/image/gui", "*.png");

    camera.bounds = Rect2i(Vector2i.zero, map.totalSize);

    playMusicTrack(playerFaction.themeSong, true);

    GC.collect(); // reduce risk of in-battle collection

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
      foreach(unit ; _activePlayer.units) {
        bool gainedCover = unit.endTurn();
        if (gainedCover) {
          auto popupPos = cast(Vector2i) (unit.center - camera.area.topLeft);
          int cover = unit.evade;
          gui.addElement(new BattlePopup(popupPos, BattlePopup.Type.cover, cover - 1, cover));
        }
      }
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

    foreach(pl ; players) {
      if (pl.maxCommandPoints == Player.baseCommandPoints) {
        states.setState(new BattleOver(pl.isLocal ? No.Victory : Yes.Victory));
        return;
      }
    }

    player.beginTurn();
    foreach(unit ; player.units) { // check if any units were killed by poison
      states.pushState(new CheckUnitDestruction(unit));
    }
    refreshBattlePanel();
  }

  void refreshBattlePanel() {
    _panel.refresh(_activePlayer);
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

  auto alliesTo(int team) {
    return playerByTeam(team).units;
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
