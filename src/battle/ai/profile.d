module battle.ai.profile;

import dau.all;
import std.range, std.algorithm;
import model.all;
import battle.battle;
import battle.ai.goal;
import battle.ai.decision;

/// An AI profile prioritizes certain actions over others
class AIProfile {
  mixin JsonizeMe;
  @jsonize {
    float claimObelisk;   /// desire to capture neutral obelisks
    float stealObelisk;   /// desire to capture enemy obelisks
    float protectObelisk; /// desire to protect allied obelisks
    float deploy;         /// desire to deploy more units
    float mobility;       /// desire to move units
    float agression;      /// desire to attack
    float support;      /// desire to attack
    float avoidCounter;   /// desire to avoid counter attacks
  }

  auto expandGoals(int team, Battle battle) {
    auto player = battle.playerByTeam(team);
    return chain(
        battle.enemiesTo(team).map!(x => makeAttackGoal(x)),
        battle.obelisks.filter!(x => x.team != team).map!(x => makeObeliskGoal(x, battle)),
        player.units.map!(x => makeAidGoal(x))
    );
  }

  private:
  auto makeAttackGoal(Unit unit) {
    return AIGoal(AIGoal.Type.attack, unit.tile, agression);
  }

  auto makeAidGoal(Unit unit) {
    return AIGoal(AIGoal.Type.aid, unit.tile, support);
  }

  auto makeObeliskGoal(Obelisk obelisk, Battle battle) {
    auto tile = battle.map.tileAt(obelisk.row, obelisk.col);
    return AIGoal(AIGoal.Type.capture, tile, claimObelisk);
  }
}

auto getAIProfile(string key) {
  assert(key in _profiles, "no ai profile named " ~ key);
  return _profiles[key];
}

private:
AIProfile[string] _profiles;

static this() {
  onInit({ _profiles = Paths.aiData.readJSON!(AIProfile[string]); });
}
