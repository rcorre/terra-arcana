module battle.state.pcturn;

import dau.all;
import model.all;
import battle.battle;
import battle.system.all;
import battle.state.playerunitselected;
import battle.state.playerturn;

/// the AI may begin moving units
class PCTurn : State!Battle {
  this(Player pc) {
    _pc = pc;
  }

  override {
    void enter(Battle b) {
      b.enableSystem!TileHoverSystem;
      b.enableSystem!BattleCameraSystem;
      _tileHoverSys = b.getSystem!TileHoverSystem;
      _cursor = new Animation("gui/tilecursor", "ally", Animation.Repeat.loop);
      if (_pc.moveableUnits.empty) {
        b.startNewTurn;
      }
    }

    void update(Battle b, float time, InputManager input) {
      _cursor.update(time);
      auto unit = _tileHoverSys.unitUnderMouse;
      if (unit !is null && input.select && unit.team == _pc.teamIdx) {
        b.states.pushState(new PlayerUnitSelected(unit));
      }
      if (input.skip) { // TODO remove when ai implemented
        b.startNewTurn;
      }
    }

    void draw(Battle b, SpriteBatch sb) {
      foreach(unit ; _pc.moveableUnits) {
        sb.draw(_cursor, unit.center);
      }
    }
  }

  private:
  TileHoverSystem _tileHoverSys;
  Animation _cursor;
  Player _pc;
}
