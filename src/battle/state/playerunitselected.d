module battle.state.playerunitselected;

import dau.all;
import model.all;
import battle.battle;
import battle.pathfinder;
import battle.system.all;
import battle.state.moveunit;
import battle.state.performaction;

class PlayerUnitSelected : State!Battle {
  this(Unit unit) {
    _unit = unit;
  }

  override {
    void enter(Battle b) {
      b.enableSystem!TileHoverSystem;
      b.disableSystem!BattleCameraSystem;
      b.lockLeftUnitInfo = false;
      b.displayUnitInfo(_unit);
      b.lockLeftUnitInfo = true;
      if (!_unit.canAct || b.activePlayer.commandPoints <= 0) {
        b.states.popState();
      }
      _tileHover = b.getSystem!TileHoverSystem;
      _pathFinder = new Pathfinder(b.map, _unit);
      _allyCursor  = new Animation("gui/tilecursor", "ally", Animation.Repeat.loop);
      _enemyCursor = new Animation("gui/tilecursor", "enemy", Animation.Repeat.loop);
      _moveCursor  = new Animation("gui/tilecursor", "move", Animation.Repeat.loop);
      _pathCursor  = new Animation("gui/tilecursor", "path", Animation.Repeat.loop);
    }

    void update(Battle b, float time, InputManager input) {
      _allyCursor.update(time);
      _enemyCursor.update(time);
      _moveCursor.update(time);
      _pathCursor.update(time);
      auto tile = _tileHover.tileUnderMouse;
      if (_tileHover.tileUnderMouseChanged) {
        _path = _pathFinder.pathTo(tile);
      }
      if (input.select) {
        if (_unit.canUseAction(1, tile)) { // TODO: handle attack ground
          b.states.pushState(new PerformAction(_unit, 1, cast(Unit) tile.entity));
        }
        else if (_path !is null) {
          b.states.pushState(new MoveUnit(_unit, _path));
        }
        else {
          b.states.popState();
        }
      }
      else if (input.altSelect && _unit.canUseAction(2, tile)) { // TODO: handle attack ground
        b.states.pushState(new PerformAction(_unit, 2, cast(Unit) tile.entity));
      }
    }

    void draw(Battle b, SpriteBatch sb) {
      foreach(tile ; _pathFinder.tilesInRange) {
        sb.draw(_moveCursor, tile.center);
      }
      foreach(tile ; _path) {
        sb.draw(_pathCursor, tile.center);
      }
      foreach(player ; b.players) {
        auto cursor = player.teamIdx == _unit.team ? _allyCursor : _enemyCursor;
        foreach(target ; player.units) {
          if (_unit.firstUseableAction(target) != 0) {
            sb.draw(cursor, target.center);
          }
        }
      }
    }

    void exit(Battle b) {
      _path = null;
    }
  }

  private:
  Unit _unit;
  Animation _allyCursor, _enemyCursor, _moveCursor, _pathCursor;
  TileHoverSystem _tileHover;
  Pathfinder _pathFinder;
  Tile[] _path;
  Player _player;
}
