module battle.state.playerturn;

import std.algorithm, std.array;
import dau.all;
import model.all;
import battle.battle;
import battle.system.all;
import battle.state.endturn;
import battle.state.considermove;
import battle.state.chooseunittodeploy;

/// player may click on a unit to issue orders
class PlayerTurn : State!Battle {
  this(Player player) {
    _player = player;
  }

  override {
    void enter(Battle b) {
      b.enableSystem!TileHoverSystem;
      b.enableSystem!BattleCameraSystem;
      _tileHoverSys = b.getSystem!TileHoverSystem;
      _cursor = new Animation("gui/overlay", "ally", Animation.Repeat.loop);
      _unitJumpList = bicycle(_player.moveableUnits.array);
      if (_player.commandPoints == 0) {
        b.startNewTurn();
        b.getSystem!BattleNetworkSystem.broadcastEndTurn(); // notify network
      }
      checkMouse(b);
    }

    void update(Battle b, float time, InputManager input) {
      _cursor.update(time);
      auto tile = _tileHoverSys.tileUnderMouse;
      auto unit = _tileHoverSys.unitUnderMouse;
      if (_tileHoverSys.tileUnderMouseChanged) {
        checkMouse(b);
      }
      
      if (input.select) {
        if (unit !is null && unit.team == _player.teamIdx) {
          b.states.pushState(new ConsiderMove(unit));
        }
        else if (_mouseOverSpawnPoint) {
          b.states.pushState(new ChooseUnitToDeploy(_player, tile));
        }
      }
      else if (input.skip) {
        b.states.pushState(new EndTurn);
      }
    }

    void draw(Battle b, SpriteBatch sb) {
      foreach(unit ; _player.moveableUnits) {
        sb.draw(_cursor, unit.center);
      }
      foreach(spawnPoint ; b.spawnPointsFor(_player.teamIdx)) {
        sb.draw(_cursor, spawnPoint.center);
      }
    }
  }

  private:
  TileHoverSystem _tileHoverSys;
  Animation _cursor;
  Player _player;
  Bicycle!(Unit[]) _unitJumpList;
  bool _mouseOverSpawnPoint;

  void checkMouse(Battle b) {
    auto tile = _tileHoverSys.tileUnderMouse;
    auto unit = _tileHoverSys.unitUnderMouse;
    _mouseOverSpawnPoint = b.spawnPointsFor(_player.teamIdx).canFind(tile);
    if (unit is null) {
      b.cursor.setSprite(_mouseOverSpawnPoint ? "active" : "inactive");
    }
    else {
      if (unit.team == _player.teamIdx) {
        b.cursor.setSprite("ally");
      }
      else {
        b.cursor.setSprite("enemy");
      }
    }
  }
}
