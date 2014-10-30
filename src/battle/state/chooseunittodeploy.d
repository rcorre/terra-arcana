module battle.state.chooseunittodeploy;

import std.algorithm;
import dau.all;
import model.all;
import battle.battle;
import battle.system.all;
import gui.deploymenu;

/// player may click on a unit to issue orders
class ChooseUnitToDeploy : State!Battle {
  this (Player player, Tile tile) {
    _player = player;
    _tile = tile;
  }

  override {
    void enter(Battle b) {
      b.disableSystem!TileHoverSystem;
      b.disableSystem!BattleCameraSystem;
      _cursor = new Animation("gui/tilecursor", "ally", Animation.Repeat.loop);
      b.gui.addElement(new DeployMenu(_player.faction.standardUnitKeys, Vector2i.zero));
    }

    void update(Battle b, float time, InputManager input) {
      _cursor.update(time);
    }

    void draw(Battle b, SpriteBatch sb) {
      sb.draw(_cursor, _tile.center);
    }
  }

  private:
  Tile _tile;
  Animation _cursor;
  Player _player;
}
