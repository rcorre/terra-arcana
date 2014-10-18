module model.unit;

import std.string : format;
import dau.setup;
import dau.entity;
import dau.util.jsonizer;
import dau.graphics.all;
import dau.geometry.all;
import model.tile;

private enum unitDepth = 1;

class Unit : Entity {
  const UnitData data;
  alias data this;

  //TODO: pass tile instead of pos?
  this(string key, Tile tile) {
    auto sprite = new Animation(key, "idle", Animation.Repeat.loop, unitDepth);
    super(tile.center, sprite, "unit");
    assert(key in _data, "no unit data matches key "  ~ key);
    data = _data[key];
    this.tile = tile;
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
  }

  private:
  Tile _tile;
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
