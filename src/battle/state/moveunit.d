module battle.state.moveunit;

import std.array;
import std.algorithm : map, sum;
import dau.all;
import model.all;
import battle.battle;
import battle.system.all;
import battle.state.triggertrap;

private enum moveRate = 200;

class MoveUnit : State!Battle {
  this(Unit unit, Tile[] path) {
    _unit = unit;
    _path = path;
    _unit.consumeAp(path.map!(x => unit.computeMoveCost(x)).sum);
    _pos = cast(Vector2f) unit.center;
  }

  override {
    void start(Battle b) {
      b.activePlayer.consumeCommandPoints(1);
      b.updateBattlePanel();
      _unit.sprite.depth += 1;  // make sure it passes over other units
    }

    void update(Battle b, float time, InputManager input) {
      auto disp = _path.back.center - _unit.center;
      auto dist = moveRate * time;
      if (dist >= disp.len) {
        if (_path.length == 1) {
          b.states.popState();
        }
        checkForTrap(b);
        _pos = cast(Vector2f) _path.back.center;
        _path.popBack();
      }
      else {
        _pos += disp.normalized * dist;
      }
      _unit.center = cast(Vector2i) _pos;
    }

    void exit(Battle b) {
      _unit.tile = b.map.tileAt(_unit.center);
    }

    void end(Battle b) {
      _unit.sprite.depth -= 1;  // return to normal depth
    }
  }

  private:
  Unit _unit;
  Tile[] _path;
  Vector2f _pos; // use float for greater precision of tracking movement

  void checkForTrap(Battle b) {
    auto trap = cast(Trap) _path.back.trap;
    if (trap !is null && trap.team != _unit.team) {
      // TODO: avoid if flying?
      b.states.pushState(new TriggerTrap(_unit.tile)); // TODO: check for each turn
    }
  }
}
