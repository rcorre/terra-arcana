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
import battle.ai.helpers;

class AIPlayer : Player {
  this(const Faction faction, int teamIdx, AIProfile profile) {
    super(faction, teamIdx, false);
    _profile = profile;
  }

  AIOption getDecision(Battle battle) {
    setEnemies(battle);
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
  Unit[]    _enemies;

  void setEnemies(Battle b) {
    _enemies = [];
    auto others = b.players.filter!(x => x != this);
    foreach(other ; others) {
      _enemies ~= other.units;
    }
  }

  auto allOptions(Battle battle) {
    return deployOptions(battle) ~ allUnitOptions(battle);
  }

  auto deployOptions(Battle battle) {
    int excessCommand = maxCommandPoints - units.map!(x => x.deployCost).sum;
    AIOption[] options;
    foreach(tile ; battle.spawnPointsFor(teamIdx).filter!(x => x.entity is null)) {
      foreach(key ; faction.standardUnitKeys) {
        auto data = getUnitData(key);
        if (data.deployCost <= commandPoints) {
          options ~= new DeployOption(key, tile, units, _enemies, excessCommand);
        }
      }
    }
    return options;
  }

  auto allUnitOptions(Battle battle) {
    AIOption[] options;
    foreach(unit ; moveableUnits) {
      options ~= unitOptions(unit, battle);
    }
    return options;
  }

  auto unitOptions(Unit unit, Battle battle) {
    return moveOptions(unit, battle) ~ actOptions(unit, battle);
  }

  auto moveOptions(Unit unit, Battle battle) {
    float current = computeTilePriority(battle, _profile, unit.tile, teamIdx);
    auto finder = new Pathfinder(battle.map, unit);
    return finder.tilesInRange
      .map!(tile => cast(AIOption) new MoveOption(unit, tile, _enemies, teamIdx, finder, current))
      .array;
  }

  auto actOptions(Unit unit, Battle battle) {
    AIOption[] options;
    foreach(enemy ; _enemies) {
      if (unit.canUseAction(1, enemy.tile)) {
        options ~= new ActOption(unit, enemy, 1);
      }
      if (unit.canUseAction(2, enemy.tile)) {
        options ~= new ActOption(unit, enemy, 2);
      }
    }
    return options;
  }
}
