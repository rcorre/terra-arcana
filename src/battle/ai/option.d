module battle.ai.option;

import battle.battle;
import battle.ai.profile;

interface AIOption {
  float computeScore(Battle b, AIProfile profile); /// higher value == more preferable option
}
