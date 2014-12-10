module battle.state.chooseunittodeploy;

import std.algorithm;
import dau.all;
import model.all;
import battle.battle;
import battle.system.all;
import battle.state.deployunit;
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
      _cursor = new Animation("gui/overlay", "ally", Animation.Repeat.loop);
      auto deploy = delegate(string key) {
        b.states.setState(new DeployUnit(_player, _tile, key));
        // notify network
        b.getSystem!BattleNetworkSystem.broadcastDeploy(key, _tile);
      };
      _menu = new DeployMenu(_player.faction, Vector2i.zero, deploy, _player.commandPoints);
      b.gui.addElement(_menu);
      auto menuHover = delegate(bool on) { b.cursor.setSprite(on ? "active" : "inactive"); };
      _menu.onHover(menuHover);
    }

    void update(Battle b, float time, InputManager input) {
      _cursor.update(time);
      if (input.skip) {
        b.states.popState();
      }
    }

    void draw(Battle b, SpriteBatch sb) {
      sb.draw(_cursor, _tile.center);
    }

    void exit(Battle b) {
      _menu.active = false;
    }
  }

  private:
  Tile       _tile;
  Animation  _cursor;
  Player     _player;
  GUIElement _menu;
}
