module battle.state.performcounter;

import std.format;
import dau.all;
import model.all;
import battle.battle;
import battle.pathfinder;
import battle.system.all;
import battle.util;
import battle.state.applyeffect;
import battle.state.checkunitdestruction;

class PerformCounter : State!Battle {
  this(Unit actor, Unit target) {
    _actor = actor;
    _target = target;
    _actionNum = actor.firstUseableCounter(target);
  }

  override {
    void enter(Battle b) {
      // no viable counter attack
      if (_actionNum == 0 || !_actor.isAlive) {
        b.states.popState();
      }
      else {
        auto action = _actor.getAction(_actionNum);
        if (action.apCost > _actor.ap) {
          b.states.popState();
        }
        else {
          auto onAnimationEnd = delegate() {
            b.states.popState();
            auto action = _actor.getAction(_actionNum);
            _tilesAffected = tilesAffected(b.map, _target.tile, _actor, action);
            foreach(enemy ; unitsAffected(b.map, _target.tile, _actor, action)) {
              for(int i = 0; i < action.hits; ++i) {
                b.states.pushState(new CheckUnitDestruction(enemy));
                b.states.pushState(new ApplyEffect(action, enemy));
              }
            }
            _actor.consumeAp(action.apCost);
          };
          _actor.playAnimation("action%d".format(_actionNum), onAnimationEnd);
          _effectAnim = _actor.getActionAnimation(_actionNum);
          _actor.getActionSound(_actionNum).play();
        }
      }
    }

    void update(Battle b, float time, InputManager input) {
      _effectAnim.update(time);
    }

    void draw(Battle b, SpriteBatch sb) {
      foreach(tile ; _tilesAffected) {
        sb.draw(_effectAnim, tile.center);
      }
    }
  }

  private:
  Tile[] _tilesAffected;
  Unit _actor, _target;
  int _actionNum;
  Animation _effectAnim;
}
