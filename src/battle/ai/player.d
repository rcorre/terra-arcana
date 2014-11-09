module battle.ai.player;

import std.algorithm, std.range, std.array;
import dau.util.math;
import model.all;
import battle.battle;
import battle.pathfinder;
import battle.ai.unitai;
import battle.ai.helpers;
import battle.ai.profile;
import battle.ai.decision;

class AIPlayer : Player {
  this(const Faction faction, int teamIdx, string profileKey) {
    super(faction, teamIdx, false);
    _profile = getAIProfile(profileKey);
  }

  AIDecision getDecision(Battle battle) {
    auto unitAIs = units.map!(x => UnitAI(x, battle, _profile));
    auto goals = _profile.expandGoals(teamIdx, battle);
    AIDecision bestOption = null;
    float bestScore = 0;
    foreach(goal ; goals) {
      AIDecision[] options;
      foreach(ai ; unitAIs) {
        auto option = ai.bestSolutionTo(goal, commandPoints);
        if (option !is null) {
          float score = option.score * goal.priority;
          if (score > bestScore) {
            bestScore = score;
            bestOption = option;
          }
        }
      }
      foreach(option ; deployOptions(battle, goal.target)) {
        float score = option.score * goal.priority;
        if (score > bestScore) {
          bestScore = score;
          bestOption = option;
        }
      }
    }

    return bestOption;
  }

  private:
  AIProfile _profile;

  auto deployOptions(Battle battle, Tile target) {
    AIDecision[] options;
    foreach(tile ; battle.spawnPointsFor(teamIdx)) {
      foreach(key ; faction.standardUnitKeys) {
        float cmdScore = 1 - units.length / maxCommandPoints;
        float distScore = proximityScore(tile, target);
        float score = average(cmdScore, distScore) * _profile.deploy;
        options ~= new DeployDecison(key, tile, score);
      }
    }
    return options;
  }
}
