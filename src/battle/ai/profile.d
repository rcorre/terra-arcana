module battle.ai.profile;

import dau.all;

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
  }
}

auto getProfile(string key) {
  assert(key in _profiles, "no ai profile named " ~ key);
  return _profiles[key];
}

private:
AIProfile[string] _profiles;

static this() {
  onInit({ _profiles = Paths.aiData.readJSON!(AIProfile[string]); });
}
