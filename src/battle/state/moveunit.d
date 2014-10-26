module battle.state.moveunit;

import std.array;
import std.algorithm : map, sum;
import dau.all;
import model.all;
import battle.battle;
import battle.system.all;

private enum moveRate = 200;

class MoveUnit : State!Battle {
  this(Unit unit, Tile[] path) {
    _unit = unit;
    _path = path;
    _unit.consumeAp(path.map!(x => x.moveCost).sum);
    _pos = cast(Vector2f) unit.center;
  }

  override {
    void update(Battle b, float time, InputManager input) {
      auto disp = _path.back.center - _unit.center;
      auto dist = moveRate * time;
      if (dist >= disp.len) {
        _pos = cast(Vector2f) _path.back.center;
        _path.popBack();
        if (_path.empty) {
          b.states.popState();
        }
      }
      else {
        _pos += disp.normalized * dist;
      }
      _unit.center = cast(Vector2i) _pos;
    }

    void exit(Battle b) {
      _unit.tile = b.map.tileAt(_unit.center);
    }
  }

  private:
  Unit _unit;
  Tile[] _path;
  Vector2f _pos; // use float for greater precision of tracking movement
}
