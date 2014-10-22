module battle.state.playerturn;

import std.algorithm : filter;
import dau.all;
import model.all;
import battle.battle;
import battle.system.all;
import battle.state.playerunitselected;

class PlayerTurn : State!Battle {
  override {
    void enter(Battle b) {
      b.enableSystem!TileHoverSystem;
      b.enableSystem!BattleCameraSystem;
      _tileHoverSys = b.getSystem!TileHoverSystem;
      _cursor = new Animation("gui/tilecursor", "ally", Animation.Repeat.loop);
    }

    void update(Battle b, float time, InputManager input) {
      _cursor.update(time);
      auto unit = _tileHoverSys.unitUnderMouse;
      if (unit !is null && input.select && unit.team == Team.player) {
        b.states.pushState(new PlayerUnitSelected(unit));
      }
    }

    void draw(Battle b, SpriteBatch sb) {
      foreach(unit ; b.moveableUnits(Team.player)) {
        sb.draw(_cursor, unit.center);
      }
    }
  }

  private:
  TileHoverSystem _tileHoverSys;
  Animation _cursor;
}
