module battle.state.playerunitselected;

import dau.all;
import model.all;
import battle.battle;
import battle.pathfinder;
import battle.system.all;
import battle.state.moveunit;

class PlayerUnitSelected : State!Battle {
  this(Unit unit) {
    _unit = unit;
  }

  override {
    void enter(Battle b) {
      b.enableSystem!TileHoverSystem;
      b.disableSystem!BattleCameraSystem;
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
      if (_tileHover.tileUnderMouseChanged) {
        _path = _pathFinder.pathTo(_tileHover.tileUnderMouse);
      }
      if (input.select && _path !is null) {
        b.states.pushState(new MoveUnit(_unit, _path));
      }
    }

    void draw(Battle b, SpriteBatch sb) {
      foreach(tile ; _pathFinder.tilesInRange) {
        sb.draw(_moveCursor, tile.center);
      }
      foreach(tile ; _path) {
        sb.draw(_pathCursor, tile.center);
      }
      foreach(unit ; b.units) {
        if (_unit.canUseAnyAction(unit)) {
          sb.draw(_unit.team == unit.team ? _allyCursor : _enemyCursor, unit.center);
        }
      }
    }
  }

  private:
  Unit _unit;
  Animation _allyCursor, _enemyCursor, _moveCursor, _pathCursor;
  TileHoverSystem _tileHover;
  Pathfinder _pathFinder;
  Tile[] _path;
}
