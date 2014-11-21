module model.faction;

import std.algorithm, std.range;
import model.unit;
import dau.all;

class Faction {
  mixin JsonizeMe;
  @jsonize {
    string name;
    string description;
    string themeSong;
    string[] standardUnitKeys;
    string[] advancedUnitKeys;
    string[] eliteUnitKeys;
  }
}

auto getFaction(string name) {
  auto faction = _factions.find!(x => x.name == name);
  assert(!faction.empty, "no faction named " ~ name);
  return faction.front;
}

auto allFactions() {
  return _factions;
}

private:
Faction[] _factions;

static this() {
  onInit({ _factions = Paths.factionData.readJSON!(Faction[]); });
}
