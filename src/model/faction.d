module model.faction;

import std.algorithm;
import model.unit;
import dau.all;

class Faction {
  @jsonize const {
    string name;
    string description;
    string[] standardUnitKeys;
    string[] advancedUnitKeys;
    string[] eliteUnitKeys;
  }
}

auto getFactionData(string name) {
  auto faction = _factions.find!(x => x.name == name);
  assert(faction !is null, "no faction named " ~ name);
  return faction.front;
}

private:
Faction[] _factions;

static this() {
  onInit({ _factions = Paths.factionData.readJSON!(Faction[]); });
}
