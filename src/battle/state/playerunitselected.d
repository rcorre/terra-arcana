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
      _pathFinder = new Pathfinder(b.map, _unit);
    }
  }

  override void update(Battle b, float time, InputManager input) {
    _unitCursor.update(time);
  }

  override void draw(Battle b, SpriteBatch sb) {
    sb.draw(_unitCursor, _unit.center);
    foreach(tile ; _pathFinder.tilesInRange) {
      sb.draw(_moveCursor, tile.center);
    }
  }

  private:
  Unit _unit;
  Animation _unitCursor, _moveCursor;
  TileHoverSystem _tileHover;
  Pathfinder _pathFinder;
}
