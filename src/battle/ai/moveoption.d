module battle.ai.moveoption;

import battle.battle;
import battle.ai.profile;
import battle.ai.option;
import model.all;

class MoveOption : AIOption {
  const Unit unit;   /// unit to move
  const Tile target; /// tile to move to

  this(Unit unit, Tile target) {
    this.unit = unit;
    this.target = target;
  }

  override float computeScore(Battle b, AIProfile profile) {
    float score = profile.mobility;
    return score;
  }
}
