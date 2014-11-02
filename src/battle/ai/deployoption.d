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

  /// excess command is maxCommand - units.sum(deployCost)
  this(string unitKey, Tile target, Unit[] allies, Unit[] enemies, int excessCommand) {
    _unitKey = unitKey;
    _target  = target;
    _allies  = allies;
    _enemies = enemies;
    _excessCommand = excessCommand;
  }

  override float computeScore(Battle b, AIProfile profile) {
    int cost = getUnitData(_unitKey).deployCost;
    return (_excessCommand - cost) + profile.deploy;
  }

  string _unitKey; /// unit to deploy
  Tile   _target;  /// tile to deploy on
  Unit[] _allies;
  Unit[] _enemies;
  int    _excessCommand;
}
