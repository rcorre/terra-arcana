module battle.state.playerunitselected;

import dau.all;
import model.all;
import battle.battle;
import battle.pathfinder;
import battle.system.all;

class PlayerUnitSelected : State!Battle {
  this(Unit unit) {
    _unit = unit;
  }

  override {
    void enter(Battle b) {
      b.enableCameraControl = true;
      b.enableSystem!TileHoverSystem;
      b.disableSystem!BattleCameraSystem;
      _tileHover = b.getSystem!TileHoverSystem;
      _unitCursor = new Animation("gui/tilecursor", "ally", Animation.Repeat.loop);
      _moveCursor = new Animation("gui/tilecursor", "move", Animation.Repeat.loop);
      _pathCursor = new Animation("gui/tilecursor", "path", Animation.Repeat.loop);
      _pathFinder = new Pathfinder(b.map, _unit);
    }
  }

  override void update(Battle b, float time, InputManager input) {
    _unitCursor.update(time);
    _moveCursor.update(time);
    _pathCursor.update(time);
    if (_tileHover.tileUnderMouseChanged) {
      _path = _pathFinder.pathTo(_tileHover.tileUnderMouse);
    }
  }

  override void draw(Battle b, SpriteBatch sb) {
    sb.draw(_unitCursor, _unit.center);
    foreach(tile ; _pathFinder.tilesInRange) {
      sb.draw(_moveCursor, tile.center);
    }
    if (_path !is null) {
      foreach(tile ; _path) {
        sb.draw(_pathCursor, tile.center);
      }
    }
  }

  private:
  Unit _unit;
  Animation _unitCursor, _moveCursor, _pathCursor;
  TileHoverSystem _tileHover;
  Pathfinder _pathFinder;
  Tile[] _path;
}
