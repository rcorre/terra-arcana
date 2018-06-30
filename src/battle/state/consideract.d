module battle.state.consideract;

import std.range, std.algorithm;
import dau.all;
import model.all;
import gui.battlepopup;
import battle.util;
import battle.battle;
import battle.system.all;
import battle.state.performaction;

private enum notEnoughApTint = color(0.5,0.5,0.5,0.5);

/// player may click to move a unit
class ConsiderAct : State!Battle {
  this(Unit unit, int actionNum) {
    _unit = unit;
    _actionNum = actionNum;
    _action = unit.getAction(actionNum);
  }

  override {
    void start(Battle b) {
      _tileHover = b.getSystem!TileHoverSystem;
      _hintSys = b.getSystem!InputHintSystem;
    }

    void enter(Battle b) {
      b.enableSystem!TileHoverSystem;
      b.disableSystem!BattleCameraSystem;
      if (!_unit.canAct || b.activePlayer.commandPoints <= 0) {
        b.states.popState();
      }
      auto overlayName = _action.isAttack ? "enemy" : "ally";
      auto targetName = _action.isAttack ? "enemy-target" : "ally-target";
      _rangeOverlay = new Animation("gui/overlay", overlayName, Animation.Repeat.loop);
      _targetOverlay = new Animation("gui/overlay", targetName, Animation.Repeat.loop);
      _tilesInRange = b.map.tilesInRange(_unit.tile, _action.minRange, _action.maxRange);
      _hasEnoughAp = _unit.apCost(_actionNum) <= _unit.ap;

      if (!_hasEnoughAp) { // gray-out range overlay if not enough ap
        _rangeOverlay.tint = notEnoughApTint;
        auto popupPos = cast(Vector2i) (_unit.center - b.camera.area.topLeft);
        b.gui.addElement(new BattlePopup(popupPos, BattlePopup.Type.notEnoughAp));
      }

      _hintSys.hideHints();
      adjustHints(b);
    }

    void update(Battle b, float time, InputManager input) {
      _rangeOverlay.update(time);
      _targetOverlay.update(time);
      auto tile = _tileHover.tileUnderMouse;
      if (_tileHover.tileUnderMouseChanged) {
        adjustHints(b);
      }
      if (input.select && _unit.canUseAction(_actionNum, tile)) {
        b.states.setState(new PerformAction(_unit, _actionNum, tile));
        // notify network
        b.getSystem!BattleNetworkSystem.broadcastAction(_unit, tile, _actionNum);
      }
      else if (!input.action1 && _actionNum == 1) {
          b.states.popState();
      }
      else if (!input.action2 && _actionNum == 2) {
          b.states.popState();
      }
    }

    void draw(Battle b, SpriteBatch sb) {
      foreach(tile ; _tilesInRange) {
        sb.draw(_rangeOverlay, tile.center);
      }
      auto tile = _tileHover.tileUnderMouse;
      if (_tilesInRange.canFind(tile) && _hasEnoughAp &&
          (_action.target == UnitAction.target.burst || _action.target == UnitAction.target.line)) {
        foreach(other ; tilesAffected(b.map, tile, _unit, _action)) {
          sb.draw(_targetOverlay, other.center);
        }
      }
    }

    void exit(Battle b) {
      b.getSystem!InputHintSystem.hideHints();
    }
  }

  private:
  bool _hasEnoughAp;
  Unit _unit;
  int _actionNum;
  const UnitAction _action;
  Animation _targetOverlay, _rangeOverlay;
  TileHoverSystem _tileHover;
  InputHintSystem _hintSys;
  Tile[] _tilesInRange;

  void adjustHints(Battle b) {
    if (_unit.canUseAction(_actionNum, _tileHover.tileUnderMouse)) {
      b.cursor.setSprite(_action.isAttack ? "enemy" : "ally");
      _hintSys.setHint(0, "lmb", "use");
    }
    else {
      b.cursor.setSprite("inactive");
      _hintSys.clearHint(0);
    }
    if (_tileHover.unitUnderMouse is null) {
      _hintSys.clearHint(1);
    }
    else {
      _hintSys.setHint(1, "rmb", "inspect");
    }
  }
}
