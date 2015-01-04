module battle.state.moveunit;

import std.array;
import std.algorithm : map, sum;
import dau.all;
import model.all;
import gui.battlepopup;
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
      b.getSystem!UndoMoveSystem.pushMove(_unit, _path);
      b.activePlayer.consumeCommandPoints(1);
      b.refreshBattlePanel();
      _unit.sprite.depth += 1;  // make sure it passes over other units
    }

    void update(Battle b, float time, InputManager input) {
      _currentTile = _path.back;
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
      if (_currentTile.entity !is null && _currentTile.entity != _unit) {
        b.states.printStateTrace();
      }
      _unit.tile = _currentTile;
      if (_unit.hasTrait(Unit.Trait.guerilla) && _currentTile.cover > 0) {
        auto popupPos = cast(Vector2i) (_unit.center - b.camera.area.topLeft);
        int cover = _unit.evade;
        b.gui.addElement(new BattlePopup(popupPos, BattlePopup.Type.cover, cover - 1, cover));
      }
    }

    void end(Battle b) {
      _unit.sprite.depth -= 1;  // return to normal depth
    }
  }

  private:
  Unit _unit;
  Tile[] _path;
  Tile _currentTile;
  Vector2f _pos; // use float for greater precision of tracking movement

  void checkForTrap(Battle b) {
    auto trap = cast(Trap) _path.back.trap;
    if (trap !is null && trap.team != _unit.team && !_unit.hasTrait(UnitData.Trait.flight)) {
      b.getSystem!UndoMoveSystem.popMove(); // cannot undo if stepped on trap
      b.states.pushState(new TriggerTrap(_path.back));
    }
  }
}
