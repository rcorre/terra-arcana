module model.unitaction;

import std.algorithm : canFind;
import dau.all;

/// each unit has two actions it can perform
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
    heal,   /// restore hp
    stun,   /// reduce ap
    armor,  /// adjust armor
    evade,  /// adjust evade
    slow,   /// double move ap cost
    toxin,  /// damage over time
    transform /// change into another unit
  }

  enum Special {
    pierce,  /// ignore armor
    precise, /// ignore evasion
    blitz,   /// cannot be countered
  }

  @property bool isAttack() const { 
    return target == Target.enemy || target == Target.ground; 
  }

  bool hasSpecial(Special special) const {
    return specials.canFind(special);
  }

  @jsonize {
    string name;
    string description;
    string transformTo; /// unit to transform to (transform type ability only)
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

