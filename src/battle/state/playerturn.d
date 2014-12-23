module battle.state.playerturn;

import std.algorithm, std.array;
import dau.all;
import model.all;
import battle.battle;
import battle.system.all;
import battle.state.endturn;
import battle.state.considermove;
import battle.state.showbattlemenu;
import battle.state.chooseunittodeploy;

/// player may click on a unit to issue orders
class PlayerTurn : State!Battle {
  this(Player player) {
    _player = player;
  }

  override {
    void start(Battle b) {
      _hintSys = b.getSystem!InputHintSystem;
      _tileHoverSys = b.getSystem!TileHoverSystem;
      _cursor = new Animation("gui/overlay", "ally", Animation.Repeat.loop);
    }

    void enter(Battle b) {
      b.enableSystem!TileHoverSystem;
      b.enableSystem!BattleCameraSystem;
      // auto end turn if out of cp
      if (_player.commandPoints == 0) {
        b.startNewTurn();
        b.getSystem!BattleNetworkSystem.broadcastEndTurn(); // notify network
      }

      _hintSys.hideHints();

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
      else if (input.exit) {
        b.states.pushState(new ShowBattleMenu);
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

    void exit(Battle b) {
      b.getSystem!InputHintSystem.hideHints();
    }
  }

  private:
  TileHoverSystem _tileHoverSys;
  InputHintSystem _hintSys;
  Animation _cursor;
  Player _player;
  bool _mouseOverSpawnPoint;

  void checkMouse(Battle b) {
    auto tile = _tileHoverSys.tileUnderMouse;
    auto unit = _tileHoverSys.unitUnderMouse;
    _mouseOverSpawnPoint = b.spawnPointsFor(_player.teamIdx).canFind(tile);

    if (unit is null) {
      b.cursor.setSprite(_mouseOverSpawnPoint ? "active" : "inactive");
      _hintSys.clearHint(1);
      if (_mouseOverSpawnPoint) {
        _hintSys.setHint(0, "lmb", "deploy");
      }
      else {
        _hintSys.clearHint(0);
      }
    }
    else {
      _hintSys.setHint(1, "rmb", "inspect");
      if (unit.team == _player.teamIdx) {
        b.cursor.setSprite("ally");
        _hintSys.setHint(0, "lmb", "select");
      }
      else {
        b.cursor.setSprite("enemy");
      }
    }
  }
}
