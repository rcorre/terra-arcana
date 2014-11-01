module battle.ai.player;

import std.algorithm, std.range, std.array;
import model.all;
import battle.battle;
import battle.pathfinder;
import battle.ai.option;
import battle.ai.profile;
import battle.ai.actoption;
import battle.ai.moveoption;
import battle.ai.deployoption;


class AIPlayer {
  this(Player player, AIProfile profile) {
    _profile = profile;
    _player = player;
  }

  AIOption getDecision(Battle battle) {
    auto options = allOptions(battle);
    AIOption bestOption = null;
    float bestScore = 0;
    foreach(option ; options) {
      float score = option.computeScore(battle, _profile);
      if (score > bestScore) {
        bestScore = score;
        bestOption = option;
      }
    }

    return bestOption;
  }

  private:
  AIProfile _profile;
  Player    _player;

  auto allOptions(Battle battle) {
    return deployOptions(battle) ~ allUnitOptions(battle);
  }

  auto deployOptions(Battle battle) {
    AIOption[] options;
    foreach(tile ; battle.spawnPointsFor(_player.teamIdx)) {
      foreach(key ; _player.faction.standardUnitKeys) {
        auto data = getUnitData(key);
        if (data.deployCost <= _player.commandPoints) {
          options ~= new DeployOption(key, tile);
        }
      }
    }
    return options;
  }

  auto allUnitOptions(Battle battle) {
    AIOption[] options;
    foreach(unit ; _player.moveableUnits) {
      options ~= unitOptions(unit, battle);
    }
    return options;
  }

  auto unitOptions(Unit unit, Battle battle) {
    return moveOptions(unit, battle) ~ actOptions(unit, battle);
  }

  auto moveOptions(Unit unit, Battle battle) {
    auto pathFinder = new Pathfinder(battle.map, unit);
    return pathFinder.tilesInRange.map!(tile => cast(AIOption) new MoveOption(unit, tile)).array;
  }

  auto actOptions(Unit unit, Battle battle) {
    AIOption[] options;
    auto others = battle.players.filter!(x => x != _player);
    foreach(player ; others) {
      foreach(other ; player.units) {
        if (unit.canUseAction(1, other.tile)) {
          options ~= new ActOption(unit, other, 1);
        }
        if (unit.canUseAction(2, other.tile)) {
          options ~= new ActOption(unit, other, 2);
        }
      }
    }
    return options;
  }
}
