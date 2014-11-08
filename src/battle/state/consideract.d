module battle.state.consideract;

import std.range;
import dau.all;
import model.all;
import battle.battle;
import battle.system.all;
import battle.state.performaction;

/// player may click to move a unit
class ConsiderAct : State!Battle {
  this(Unit unit, int actionNum) {
    _unit = unit;
    _actionNum = actionNum;
    _action = unit.getAction(actionNum);
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
      auto overlayName = _action.isAttack ? "enemy" : "ally";
      _targetOverlay = new Animation("gui/overlay", overlayName, Animation.Repeat.loop);
      _tilesInRange = b.map.tilesInRange(_unit.tile, _action.minRange, _action.maxRange);
    }

    void update(Battle b, float time, InputManager input) {
      _targetOverlay.update(time);
      auto tile = _tileHover.tileUnderMouse;
      if (input.select && _unit.canUseAction(_actionNum, tile)) {
        b.states.setState(new PerformAction(_unit, _actionNum, cast(Unit) tile.entity));
      }
      else if (input.action1) {
        if (_actionNum == 1) {
          b.states.popState();
        }
        else {
          b.states.setState(new ConsiderAct(_unit, 1));
        }
      }
      else if (input.action2) {
        if (_actionNum == 2) {
          b.states.popState();
        }
        else {
          b.states.setState(new ConsiderAct(_unit, 2));
        }
      }
    }

    void draw(Battle b, SpriteBatch sb) {
      foreach(tile ; _tilesInRange) {
        sb.draw(_targetOverlay, tile.center);
      }
    }
  }

  private:
  Unit _unit;
  int _actionNum;
  const UnitAction _action;
  Animation _targetOverlay;
  TileHoverSystem _tileHover;
  Tile[] _tilesInRange;
}
