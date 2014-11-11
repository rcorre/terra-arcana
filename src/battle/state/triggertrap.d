module battle.state.triggertrap;

import dau.all;
import model.all;
import battle.battle;
import battle.system.all;
import battle.state.applyeffect;
import battle.state.checkunitdestruction;

class TriggerTrap : State!Battle {
  this(Tile tile) {
    assert(tile.trap !is null, "no trap found on tile");
    _tile = tile;
    _unit = cast(Unit) tile.entity;
    _trap = cast(Trap) tile.trap;
  }

  override {
    void start(Battle b) {
      _animation = _trap.getTriggerAnimation(delegate() { b.states.popState; });
      b.lockLeftUnitInfo = false;
      b.displayUnitInfo(_unit);
      b.lockLeftUnitInfo = true;
      auto trap = cast(Trap) _tile.trap;
      _tile.trap = null;
      b.entities.removeEntity(trap);
    }

    void update(Battle b, float time, InputManager input) {
      _animation.update(time);
    }

    void exit(Battle b) {
      for(int i = 0; i < _trap.effect.hits; ++i) {
        b.states.pushState(new CheckUnitDestruction(_unit));
        b.states.pushState(new ApplyEffect(_trap.effect, _unit));
      }
    }
  }

  private:
  Tile _tile;
  Unit _unit;
  Trap _trap;
  Animation _animation;
}
