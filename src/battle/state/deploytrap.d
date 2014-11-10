module battle.state.deploytrap;

import dau.all;
import model.all;
import battle.battle;
import battle.pathfinder;
import battle.system.all;
import battle.state.delay;

/// apply the result of a single hit of an action
class DeployTrap : State!Battle {
  this(Unit user, const UnitAction action, Tile target) {
    _user = user;
    _target = target;
    _action = action;
  }

  override { // TODO: show effect on status bar
    void enter(Battle b) {
      assert(_target.trap is null, "cannot deply a second trap on a tile");
      auto trap = new Trap(_user.key, _user.center, _user.team, _action);
      _target.trap = trap;
      b.entities.registerEntity(trap);
      b.states.setState(new Delay()); // pause briefly after applying effect
    }
  }

  private:
  Unit _user;
  const UnitAction _action;
  Tile _target;
}
