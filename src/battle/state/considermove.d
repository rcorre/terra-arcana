module battle.state.considermove;

import std.range;
import dau.all;
import model.all;
import battle.battle;
import battle.pathfinder;
import battle.system.all;
import battle.state.moveunit;
import battle.state.undomove;
import battle.state.consideract;
import battle.state.showbattlemenu;

/// player may click to move a unit
class ConsiderMove : State!Battle {
  this(Unit unit) {
    _unit = unit;
  }

  override {
    void start(Battle b) {
      _tileHover = b.getSystem!TileHoverSystem;
      _hintSys = b.getSystem!InputHintSystem;

      _allyCursor  = new Animation("gui/overlay", "ally", Animation.Repeat.loop);
      _enemyCursor = new Animation("gui/overlay", "enemy", Animation.Repeat.loop);
      _moveCursor  = new Animation("gui/overlay", "move", Animation.Repeat.loop);
      _pathCursor  = new Animation("gui/overlay", "path", Animation.Repeat.loop);
    }

    void enter(Battle b) {
      b.enableSystem!TileHoverSystem;
      b.disableSystem!BattleCameraSystem;

      _pathFinder = new Pathfinder(b.map, _unit);
      if (!_unit.canAct || _pathFinder.tilesInRange.empty || b.activePlayer.commandPoints <= 0) {
        b.states.popState();
      }

      _hintSys.hideHints();

      if (!b.getSystem!UndoMoveSystem.empty) {
        _hintSys.setHint(2, "u", "undo");
      }

      adjustHints(b);
    }

    void update(Battle b, float time, InputManager input) {
      _allyCursor.update(time);
      _enemyCursor.update(time);
      _moveCursor.update(time);
      _pathCursor.update(time);
      if (_tileHover.tileUnderMouseChanged) {
        auto tile = _tileHover.tileUnderMouse;
        _path = _pathFinder.pathTo(tile);
        adjustHints(b);
      }
      if (input.select) {
        if (_path is null || _path.empty) {
          b.states.popState();
          auto other = _tileHover.unitUnderMouse;
          if (other !is null && other.team == _unit.team) {
            b.states.pushState(new ConsiderMove(other));
          }
        }
        else {
          b.states.pushState(new MoveUnit(_unit, _path));
          // send notification over network
          auto net = b.getSystem!BattleNetworkSystem;
          net.broadcastMove(_unit, _path);
        }
      }
      else if (input.inspect && _tileHover.unitUnderMouse is null) {
        b.states.popState();
      }
      else if (input.skip) {
        b.states.popState();
      }
      else if (input.action1) {
        b.states.pushState(new ConsiderAct(_unit, 1));
      }
      else if (input.action2) {
        b.states.pushState(new ConsiderAct(_unit, 2));
      }
      else if (input.exit) {
        b.states.pushState(new ShowBattleMenu);
      }
      else if (input.undo) {
        b.states.pushState(new UndoMove);
        b.getSystem!BattleNetworkSystem.broadcastUndo();
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
      b.getSystem!InputHintSystem.hideHints();
      _path = null;
    }
  }

  private:
  Unit _unit;
  Animation _allyCursor, _enemyCursor, _moveCursor, _pathCursor;
  TileHoverSystem _tileHover;
  InputHintSystem _hintSys;
  Pathfinder _pathFinder;
  Tile[] _path;

  void adjustHints(Battle b) {
    if (_path !is null) {
      _hintSys.setHint(0, "lmb", "move");
      b.cursor.setSprite("active");
    }
    else {
      _hintSys.clearHint(0);
      b.cursor.setSprite("inactive");
    }
    auto other = _tileHover.unitUnderMouse;
    if (other !is null) {
      _hintSys.setHint(1, "rmb", "inspect");
      if (other.team == _unit.team && other.canAct) {
        b.cursor.setSprite("ally");
        _hintSys.setHint(0, "lmb", "select");
      }
    }
    else {
      _hintSys.setHint(1, "rmb", "cancel");
    }
  }

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
