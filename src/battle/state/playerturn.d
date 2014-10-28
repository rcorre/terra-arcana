module battle.state.playerturn;

import std.algorithm : filter;
import dau.all;
import model.all;
import battle.battle;
import battle.system.all;
import battle.state.playerunitselected;
import battle.state.pcturn;

/// player may click on a unit to issue orders
class PlayerTurn : State!Battle {
  override {
    void start(Battle b) {
      foreach(unit ; b.units.filter!(x => x.team == Team.player)) {
        unit.startTurn();
      }
    }

    void end(Battle b) {
      foreach(unit ; b.units.filter!(x => x.team == Team.player)) {
        unit.endTurn();
      }
    }

    void enter(Battle b) {
      b.enableSystem!TileHoverSystem;
      b.enableSystem!BattleCameraSystem;
      b.leftUnitInfoLock = false;
      _tileHoverSys = b.getSystem!TileHoverSystem;
      _cursor = new Animation("gui/tilecursor", "ally", Animation.Repeat.loop);
      if (b.moveableUnits.empty) {
        b.states.setState(new PCTurn);
      }
    }

    void update(Battle b, float time, InputManager input) {
      _cursor.update(time);
      auto unit = _tileHoverSys.unitUnderMouse;
      if (unit !is null && input.select && unit.team == Team.player) {
        b.states.pushState(new PlayerUnitSelected(unit));
      }
      if (input.skip) {
        b.states.setState(new PCTurn);
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
auto moveableUnits(Battle b) { return b.units.filter!(x => x.team == Team.player && x.canAct); }
