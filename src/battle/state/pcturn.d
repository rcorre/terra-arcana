module battle.state.pcturn;

import dau.all;
import model.all;
import battle.battle;
import battle.system.all;
import battle.state.playerunitselected;
import battle.state.playerturn;

/// the AI may begin moving units
class PCTurn : State!Battle {
  override {
    void start(Battle b) {
      foreach(unit ; b.units.filter!(x => x.team == Team.pc)) {
        unit.startTurn();
      }
    }

    void end(Battle b) {
      foreach(unit ; b.units.filter!(x => x.team == Team.pc)) {
        unit.endTurn();
      }
    }

    void enter(Battle b) {
      b.enableSystem!TileHoverSystem;
      b.enableSystem!BattleCameraSystem;
      _tileHoverSys = b.getSystem!TileHoverSystem;
      _cursor = new Animation("gui/tilecursor", "ally", Animation.Repeat.loop);
      if (b.moveableUnits.empty) {
        b.states.setState(new PlayerTurn);
      }
    }

    void update(Battle b, float time, InputManager input) {
      _cursor.update(time);
      auto unit = _tileHoverSys.unitUnderMouse;
      if (unit !is null && input.select && unit.team == Team.pc) {
        b.states.pushState(new PlayerUnitSelected(unit));
      }
      if (input.skip) { // TODO remove when ai implemented
        b.states.setState(new PlayerTurn);
      }
    }

    void draw(Battle b, SpriteBatch sb) {
      foreach(unit ; b.moveableUnits) {
        sb.draw(_cursor, unit.center);
      }
    }
  }

  private:
  TileHoverSystem _tileHoverSys;
  Animation _cursor;
}

private:
auto moveableUnits(Battle b) { return b.units.filter!(x => x.team == Team.pc && x.canAct); }
