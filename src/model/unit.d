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

  @jsonize {
    string name;
    string description;
    int apCost;
    int power;  /// damage or healing
    int hits;   /// number of times to hit
    int minRange;
    int maxRange;

    bool piercing;
    bool precise;
  }
}

private:
UnitData[string] _data;

static this() {
  onInit({ _data = Paths.unitData.readJSON!(UnitData[string]); });
}
