module battle.battle;

import std.range, std.algorithm;
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
      new Player(getFaction("Human"), 0, true,  baseCommandPoints),
      new Player(getFaction("Gaia"),  1, false, baseCommandPoints)
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
      map = new TileMap("test", entities);
      entities.registerEntity(map);
      camera.bounds = Rect2f(Vector2f.zero, cast(Vector2f) map.totalSize);
      spawnUnit("sniper", _players[0], map.tileAt(3,3));
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
  }

  private:
  BattlePanel _battlePanel;
  Cycle!(Player[]) _turnCycle;
  Player _activePlayer;
  Player[] _players;
  bool _lockLeftUnitInfo;
}
