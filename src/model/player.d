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
    this.faction = faction;
    this.teamIdx = teamIdx;
    this.isHuman = isHuman;
    _maxCommandPoints = baseCommandPoints;
  }

  @property {
    int commandPoints() { return _commandPoints; }
    int maxCommandPoints() { return _maxCommandPoints; }

    auto units() { return _units[]; }
    auto moveableUnits() { return _units.filter!(x => x.canAct); }
  }

  void consumeCommandPoints(int amount) {
    assert(amount <= _commandPoints,
        "tried to consume %d/%d command points".format(amount, _commandPoints));
    _commandPoints -= amount;
  }

  void endTurn() {
    foreach(unit ; units) {
      unit.endTurn();
    }
  }

  void beginTurn() {
    foreach(unit ; units) {
      unit.startTurn();
    }
    _commandPoints = maxCommandPoints;
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
