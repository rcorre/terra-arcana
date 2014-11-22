module battle.state.triggertrap;

import dau.all;
import model.all;
import battle.battle;
import battle.system.all;
import battle.state.applyeffect;
import battle.state.checkunitdestruction;

class TriggerTrap : State!Battle {
  this(Tile tile) {
    _tile = tile;
  }

  override {
    void start(Battle b) {
      assert(_tile.trap !is null, "no trap found on tile");
      auto unit = cast(Unit) _tile.entity;
      auto trap = cast(Trap) _tile.trap;
      auto onEnd = delegate() {
        b.states.popState();
        b.states.pushState(new CheckUnitDestruction(unit));
        for(int i = 0; i < trap.effect.hits; ++i) {
          b.states.pushState(new ApplyEffect(trap.effect, unit));
        }
      };
      _animation = trap.getTriggerAnimation(onEnd);
      b.lockLeftUnitInfo = false;
      b.displayUnitInfo(unit);
      b.lockLeftUnitInfo = true;
      _tile.trap = null;
      b.entities.removeEntity(trap);
      trap.getTriggerSound().play();
    }

    void update(Battle b, float time, InputManager input) {
      _animation.update(time);
    }

    void draw(Battle b, SpriteBatch sb) {
      sb.draw(_animation, _tile.center);
    }
  }

  private:
  Tile _tile;
  Animation _animation;
}
