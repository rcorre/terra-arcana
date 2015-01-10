module battle.ai.player;

import std.algorithm, std.range, std.array, std.random;
import dau.util.math;
import model.all;
import battle.battle;
import battle.pathfinder;
import battle.ai.unitai;
import battle.ai.helpers;
import battle.ai.profile;
import battle.ai.decision;

private enum deployVariance = 0.1f;

class AIPlayer : Player {
  this(const Faction faction, int teamIdx, string profileKey, int baseCP) {
    super(faction, teamIdx, false, baseCP);
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
        auto data = getUnitData(key);
        if (data.deployCost > commandPoints) { continue; }
        float cmdScore = 1 - units.length / maxCommandPoints;
        float distScore = proximityScore(tile, target);
        float variance = uniform(0f, deployVariance);
        float score = average(cmdScore, distScore) * _profile.deploy + variance;
        options ~= new DeployDecison(key, tile, score);
      }
    }
    return options;
  }
}
