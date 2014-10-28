module battle.battle;

import std.range;
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
    auto players = [
      new Player(getFaction("Human"), true, baseCommandPoints),
      new Player(getFaction("Gaia"), false, baseCommandPoints),
    ];
    System!Battle[] systems = [
      new TileHoverSystem(this),
      new BattleCameraSystem(this),
    ];
    super(systems);
    _battlePanel = new BattlePanel;
    gui.addElement(_battlePanel);
    _players = cycle(players);
    startNewTurn;
  }

  override {
    void enter() {
      map = new TileMap("test", entities);
      entities.registerEntity(map);
      camera.bounds = Rect2f(Vector2f.zero, cast(Vector2f) map.totalSize);
      auto unit = new Unit("assault", map.tileAt(3, 3), Team.player);
      entities.registerEntity(unit);
      units ~= unit;
      unit = new Unit("treant", map.tileAt(5, 3), Team.pc);
      entities.registerEntity(unit);
      units ~= unit;
      unit = new Unit("guardian", map.tileAt(3, 5), Team.player);
      entities.registerEntity(unit);
      units ~= unit;
    }

    void update(float time) {
      super.update(time);
    }
  }

  package:
  TileMap map;
  Unit[]  units;
  bool leftUnitInfoLock;
  Cycle!(Player[]) _players;

  void displayUnitInfo(Unit unit) {
    if (leftUnitInfoLock) {
      _battlePanel.setRightUnitInfo(unit);
    }
    else {
      _battlePanel.setLeftUnitInfo(unit);
    }
  }

  void startNewTurn() {
    auto player = _players.front;
    _players.popFront;
    if (!states.empty) {
      states.popState();
    }
    assert(states.empty, "extra states on stack when starting new turn");
    states.pushState(player.isHuman ? new PlayerTurn(player) : new PCTurn(player));
  }

  private:
  BattlePanel _battlePanel;
}
