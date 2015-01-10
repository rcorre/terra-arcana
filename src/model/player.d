module model.player;

import std.algorithm;
import dau.util.math;
import model.faction;
import model.unit;

class Player {
  private enum defaultCP = 2;

  const Faction faction;
  const bool isLocal;
  const int teamIdx;
  const int baseCommandPoints;
  int mana;

  this(const Faction faction, int teamIdx, bool isLocal, int baseCommandPoints) {
    this.faction = faction;
    this.teamIdx = teamIdx;
    this.isLocal = isLocal;
    this.baseCommandPoints = baseCommandPoints;
    _maxCommandPoints = baseCommandPoints;
  }

  @property {
    int commandPoints() { return _commandPoints; }
    ref int maxCommandPoints() { return _maxCommandPoints; }

    auto units() { return _units[]; }
    auto moveableUnits() { return _units.filter!(x => x.canAct); }
  }

  void consumeCommandPoints(int amount) {
    assert(amount <= _commandPoints,
        "tried to consume %d/%d command points".format(amount, _commandPoints));
    _commandPoints -= amount;
  }

  void restoreCommandPoints(int amount) {
    assert(_commandPoints + amount <= _maxCommandPoints,
        "tried to add %d CP, but already have %d/%d"
        .format(amount, _commandPoints, _maxCommandPoints));
    _commandPoints += amount;
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
