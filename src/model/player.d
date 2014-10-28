module model.player;

import std.algorithm;
import dau.util.math;
import model.faction;
import model.unit;

class Player {
  const Faction faction;
  const bool isHuman;
  const int teamIdx;
  int mana;

  this(const Faction faction, int teamIdx, bool isHuman, int baseCommandPoints) {
    this.faction          = faction;
    this.teamIdx          = teamIdx;
    this.isHuman          = isHuman;
    this.maxCommandPoints = baseCommandPoints;
    this.commandPoints    = baseCommandPoints;
  }

  @property {
    int commandPoints() { return _commandPoints; }
    void commandPoints(int val) {
      _commandPoints = val.clamp(0, _maxCommandPoints);
    }

    int maxCommandPoints() { return _maxCommandPoints; }
    void maxCommandPoints(int val) {
      _maxCommandPoints = val;
      commandPoints = commandPoints;  // bring down to new max
    }

    auto units() { return _units[]; }
    auto moveableUnits() { return _units.filter!(x => x.canAct); }
  }

  void registerUnit(Unit unit) {
    _units ~= unit;
  }

  void destroyUnit(Unit unit) {
    _units = _units.remove!(x => x == unit);
  }

  private:
  int _commandPoints, _maxCommandPoints;
  Unit[] _units;
}
