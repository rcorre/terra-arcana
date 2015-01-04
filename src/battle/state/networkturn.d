module battle.state.networkturn;

import std.array;
import dau.all;
import net.all;
import model.all;
import battle.ai.all;
import battle.battle;
import battle.system.all;
import battle.state.moveunit;
import battle.state.undomove;
import battle.state.performaction;
import battle.state.deployunit;

/// turn of player over the network
class NetworkTurn : State!Battle {
  this(Player player) {
    _player = player;
  }

  override {
    void enter(Battle b) {
      b.cursor.setSprite("wait");
      b.disableSystem!TileHoverSystem;
      b.enableSystem!BattleCameraSystem;

      b.getSystem!BattleNetworkSystem.setHandler((msg) => handleMessage(msg, b));
    }

    void end(Battle b) {
      b.cursor.setSprite("inactive");
    }
  }

  private:
  Player _player;

  void handleMessage(NetworkMessage msg, Battle b) {
    switch (msg.type) with (NetworkMessage.Type) {
      case deployUnit:
        auto deploy = msg.deployUnit;
        auto location = deploy.location.getTile(b.map);
        auto unitKey = deploy.unitKey;
        b.states.pushState(new DeployUnit(_player, location, unitKey));
        break;
      case moveUnit:
        auto move = msg.moveUnit;
        auto unit = cast(Unit) move.start.getTile(b.map).entity;
        assert(unit !is null, "move unit message: no unit at start");
        auto path = move.path[0 .. cast(size_t) move.pathLength];
        auto tiles = path.map!(x => x.getTile(b.map)).array;
        b.states.pushState(new MoveUnit(unit, tiles));
        break;
      case performAction:
        auto act = msg.performAction;
        auto actor = cast(Unit) act.start.getTile(b.map).entity;
        auto target = act.target.getTile(b.map);
        auto actionNum = cast(int) act.actionNum;
        b.states.pushState(new PerformAction(actor, actionNum, target));
        break;
      case undoMove:
        b.states.pushState(new UndoMove());
        break;
      case endTurn:
        b.startNewTurn;
        break;
      default:
    }
  }
}
