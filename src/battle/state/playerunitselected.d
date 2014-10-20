module battle.state.playerunitselected;

import dau.all;
import model.all;
import battle.battle;
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
      _cursor = new Animation("gui/tilecursor", "ally", Animation.Repeat.loop);
    }
  }

  override void update(Battle b, float time, InputManager input) {
    _cursor.update(time);
  }

  override void draw(Battle b, SpriteBatch sb) {
    sb.draw(_cursor, _unit.center);
  }

  private:
  Unit _unit;
  Animation _cursor;
  TileHoverSystem _tileHover;
}
