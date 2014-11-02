module battle.ai.deployoption;

import battle.battle;
import battle.ai.profile;
import battle.ai.option;
import model.all;

class DeployOption : AIOption {
  @property {
    string unitKey() { return _unitKey; }
    Tile target()    { return _target; }
  }

  this(string unitKey, Tile target, Unit[] allies, Unit[] enemies, int command) {
    _unitKey = unitKey;
    _target  = target;
    _allies  = allies;
    _enemies = enemies;
    _command = command;
  }

  override float computeScore(Battle b, AIProfile profile) {
    return _command - _allies.length;
  }

  string _unitKey; /// unit to deploy
  Tile   _target;  /// tile to deploy on
  Unit[] _allies;
  Unit[] _enemies;
  int    _command;
}
