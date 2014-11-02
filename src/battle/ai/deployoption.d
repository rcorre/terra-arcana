module battle.ai.deployoption;

import std.random;
import battle.battle;
import battle.ai.profile;
import battle.ai.option;
import model.all;

private enum {
  randMin = 0.8,
  randMax = 1.2
}

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
    return ((_excessCommand - cost) + profile.deploy) * uniform(randMin, randMax);
  }

  string _unitKey; /// unit to deploy
  Tile   _target;  /// tile to deploy on
  Unit[] _allies;
  Unit[] _enemies;
  int    _excessCommand;
}
