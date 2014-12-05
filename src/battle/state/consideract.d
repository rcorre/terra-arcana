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
      if (!_unit.canAct || b.activePlayer.commandPoints <= 0) {
        b.states.popState();
      }
      _tileHover = b.getSystem!TileHoverSystem;
      adjustCursor(b);
      auto overlayName = _action.isAttack ? "enemy" : "ally";
      auto targetName = _action.isAttack ? "enemy-target" : "ally-target";
      _rangeOverlay = new Animation("gui/overlay", overlayName, Animation.Repeat.loop);
      _targetOverlay = new Animation("gui/overlay", targetName, Animation.Repeat.loop);
      _tilesInRange = b.map.tilesInRange(_unit.tile, _action.minRange, _action.maxRange);
    }

    void update(Battle b, float time, InputManager input) {
      _rangeOverlay.update(time);
      _targetOverlay.update(time);
      auto tile = _tileHover.tileUnderMouse;
      if (_tileHover.tileUnderMouseChanged) {
        adjustCursor(b);
      }
      if (input.select && _unit.canUseAction(_actionNum, tile)) {
        b.states.setState(new PerformAction(_unit, _actionNum, tile));
        // notify network
        b.getSystem!BattleNetworkSystem.broadcastAction(_unit, tile, _actionNum);
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
      else if (input.altSelect || input.skip) {
        b.states.popState();
      }
    }

    void draw(Battle b, SpriteBatch sb) {
      foreach(tile ; _tilesInRange) {
        sb.draw(_rangeOverlay, tile.center);
      }
      auto tile = _tileHover.tileUnderMouse;
      if (_tilesInRange.canFind(tile) && _action.target == UnitAction.target.burst) {
        sb.draw(_targetOverlay, tile.center);
        foreach(neighbor ; b.map.neighbors(tile)) {
          sb.draw(_targetOverlay, neighbor.center);
        }
      }
    }
  }

  private:
  Unit _unit;
  int _actionNum;
  const UnitAction _action;
  Animation _targetOverlay, _rangeOverlay;
  TileHoverSystem _tileHover;
  Tile[] _tilesInRange;

  void adjustCursor(Battle b) {
    if (_unit.canUseAction(_actionNum, _tileHover.tileUnderMouse)) {
      b.cursor.setSprite(_action.isAttack ? "enemy" : "ally");
    }
    else {
      b.cursor.setSprite("inactive");
    }
  }
}
