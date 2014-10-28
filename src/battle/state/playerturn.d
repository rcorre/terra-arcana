module battle.state.playerturn;

import std.algorithm : filter;
import dau.all;
import model.all;
import battle.battle;
import battle.system.all;
import battle.state.playerunitselected;

/// player may click on a unit to issue orders
class PlayerTurn : State!Battle {
  this(Player player) {
    _player = player;
  }

  override {
    void enter(Battle b) {
      b.enableSystem!TileHoverSystem;
      b.enableSystem!BattleCameraSystem;
      b.leftUnitInfoLock = false;
      _tileHoverSys = b.getSystem!TileHoverSystem;
      _cursor = new Animation("gui/tilecursor", "ally", Animation.Repeat.loop);
      if (_player.moveableUnits.empty) {
        b.startNewTurn;
      }
    }

    void update(Battle b, float time, InputManager input) {
      _cursor.update(time);
      auto unit = _tileHoverSys.unitUnderMouse;
      if (unit !is null && input.select && unit.team == _player.teamIdx) {
        b.states.pushState(new PlayerUnitSelected(unit));
      }
      if (input.skip) {
        b.startNewTurn;
      }
    }

    void draw(Battle b, SpriteBatch sb) {
      foreach(unit ; _player.moveableUnits) {
        sb.draw(_cursor, unit.center);
      }
    }
  }

  private:
  TileHoverSystem _tileHoverSys;
  Animation _cursor;
  Player _player;
}
