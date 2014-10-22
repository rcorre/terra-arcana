module model.unit;

import std.string : format;
import dau.setup;
import dau.entity;
import dau.util.jsonizer;
import dau.graphics.all;
import dau.geometry.all;
import model.tile;

enum Team {
  player,
  pc
}

class Unit : Entity {
  const Team team;
  const UnitData data;
  alias data this;

  this(string key, Tile tile, Team team) {
    auto sprite = new Animation(key, "idle", Animation.Repeat.loop);
    super(tile.center, sprite, "unit");
    assert(key in _data, "no unit data matches key "  ~ key);
    data = _data[key];
    this.tile = tile;
    _hp = data.maxHp;
    _ap = data.maxHp;
    this.team = team;
  }

  @property {
    auto tile() { return _tile; }
    auto tile(Tile newTile) {
      assert(newTile.entity is null, "cannot place %s on tile %d,%d which already has entity"
          .format(name, newTile.row, newTile.col));
      _tile = newTile;
      _tile.entity = this;
      center = tile.center;
    }

    int hp() { return _hp; }
    int ap() { return _ap; }

    bool canAct() { return _ap > 0; }
  }

  void consumeAp(int amount) {
    assert(amount <= _ap, "tried to consume %d ap when only %d available".format(amount, _ap));
    _ap -= amount;
  }

  override void update(float time) {
    if (canAct) { super.update(time); } // only animate sprite if ap > 0
  }

  private:
  Tile _tile;
  int _hp, _ap;
}

class UnitData {
  mixin JsonizeMe;

  @jsonize {
    string name;
    int deployCost;
    int maxHp;
    int maxAp;
    int baseArmor;
    int baseEvade;
    UnitAction action1, action2;
  }
}

class UnitAction {
  mixin JsonizeMe;

  enum Target {
    enemy,
    ally,
    self,
    ground
  }

  enum Effect {
    damage, /// reduce hp
    stun,   /// reduce ap
    heal,   /// restore hp
    armor,  /// adjust armor
    evade,  /// adjust evade
  }

  enum Special {
    pierce,  /// ignore armor
    precise, /// ignore evasion
    blitz,   /// cannot be countered
  }

  @jsonize {
    string name;
    string description;
    Target target;
    Effect effect;
    int apCost;
    int power;  /// damage or healing
    int hits;   /// number of times to hit
    int minRange;
    int maxRange;
    Special[] specials;
  }
}

private:
UnitData[string] _data;

static this() {
  onInit({ _data = Paths.unitData.readJSON!(UnitData[string]); });
}
