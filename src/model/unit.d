module model.unit;

import dau.engine;
import dau.entity;
import dau.util.jsonizer;
import dau.graphics.all;
import dau.geometry.all;
import dau.tool.tiled;

class Unit : Entity {
  const UnitData data;
  alias data this;

  //TODO: pass tile instead of pos?
  this(string key, Vector2i pos) {
    auto sprite = new Animation(key, "idle", Animation.Repeat.loop);
    super(pos, sprite, "unit");
    assert(key in _data, "no unit data matches key "  ~ key);
    data = _data[key];
  }
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
