module battle.state.considermove;

import std.range;
import dau.all;
import model.all;
import battle.battle;
import battle.pathfinder;
import battle.system.all;
import battle.state.consideract;
import battle.state.moveunit;

/// player may click to move a unit
class ConsiderMove : State!Battle {
  this(Unit unit) {
    _unit = unit;
  }

  override {
    void enter(Battle b) {
      b.enableSystem!TileHoverSystem;
      b.disableSystem!BattleCameraSystem;
      if (!_unit.canAct || b.activePlayer.commandPoints <= 0) {
        b.states.popState();
      }
      _tileHover = b.getSystem!TileHoverSystem;
      _pathFinder = new Pathfinder(b.map, _unit);
      b.cursor.setSprite((_pathFinder.tilesInRange.empty) ? "inactive" : "active");
      _allyCursor  = new Animation("gui/overlay", "ally", Animation.Repeat.loop);
      _enemyCursor = new Animation("gui/overlay", "enemy", Animation.Repeat.loop);
      _moveCursor  = new Animation("gui/overlay", "move", Animation.Repeat.loop);
      _pathCursor  = new Animation("gui/overlay", "path", Animation.Repeat.loop);
    }

    void update(Battle b, float time, InputManager input) {
      _allyCursor.update(time);
      _enemyCursor.update(time);
      _moveCursor.update(time);
      _pathCursor.update(time);
      if (_tileHover.tileUnderMouseChanged) {
        auto tile = _tileHover.tileUnderMouse;
        _path = _pathFinder.pathTo(tile);
      }
      if (input.select && _path !is null && !_path.empty) {
        b.states.pushState(new MoveUnit(_unit, _path));
        // send notification over network
        auto net = b.getSystem!BattleNetworkSystem;
        net.broadcastMove(_unit, _path);
      }
      else if (input.altSelect || input.skip) {
        b.states.popState();
      }
      else if (input.action1) {
        b.states.pushState(new ConsiderAct(_unit, 1));
      }
      else if (input.action2) {
        b.states.pushState(new ConsiderAct(_unit, 2));
      }
    }

    void draw(Battle b, SpriteBatch sb) {
      foreach(tile ; _pathFinder.tilesInRange) {
        sb.draw(_moveCursor, tile.center);
      }
      if (_path !is null && !_path.empty) {
        drawPath(sb, _unit.tile, _path, _pathCursor);
      }
      foreach(player ; b.players) {
        auto cursor = player.teamIdx == _unit.team ? _allyCursor : _enemyCursor;
        foreach(target ; player.units) {
          if (_unit.firstUseableAction(target) != 0) {
            sb.draw(cursor, target.center);
          }
        }
      }
    }

    void exit(Battle b) {
      _path = null;
    }
  }

  private:
  Unit _unit;
  Animation _allyCursor, _enemyCursor, _moveCursor, _pathCursor;
  TileHoverSystem _tileHover;
  Pathfinder _pathFinder;
  Tile[] _path;
  Player _player;

  void drawPath(SpriteBatch sb, Tile start, Tile[] tiles, Sprite icon) {
    auto r1 = chain(only(start), tiles.retro);
    auto r2 = tiles.retro;
    foreach(prev, next ; lockstep(r1, r2)) {
      auto dir = (next.center - prev.center);
      auto pos = prev.center + dir / 2;
      auto angle = dir.angle;
      sb.draw(icon, pos, angle);
    }

  }
}
