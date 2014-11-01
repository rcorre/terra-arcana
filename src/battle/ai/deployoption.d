module battle.ai.deployoption;

import battle.battle;
import battle.ai.profile;
import battle.ai.option;
import model.all;

class DeployOption : AIOption {
  const string unitKey; /// unit to deploy
  const Tile target;    /// tile to deploy on

  this(string unitKey, Tile target) {
    this.unitKey = unitKey;
    this.target = target;
  }

  override float computeScore(Battle b, AIProfile profile) {
    float score = profile.deploy;
    return score;
  }
}
