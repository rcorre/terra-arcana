module model.unit;

import std.string : format;
import std.algorithm : canFind, max;
import dau.all;
import model.tile;

enum Team {
  player,
  pc
}

private enum {
  damageFlashColor = Color.red,
  damageFlashTime = 0.2f,
  dodgeFlashColor = Color(1, 1, 1, 0.5),
  dodgeFlashTime = 0.2f,
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
    _key = key;
    _damageSound = new SoundSample("damage");
  }

  @property {
    auto tile() { return _tile; }
    auto tile(Tile newTile) {
      assert(newTile.entity is null, "cannot place %s on tile %d,%d which already has entity"
          .format(name, newTile.row, newTile.col));
      if (tile !is null) {
        tile.entity = null; // remove self from previous tile
      }
      _tile = newTile;
      _tile.entity = this;
      center = tile.center;
    }

    int hp() { return _hp; }
    int ap() { return _ap; }

    int evade() { return _evade; }
    int armor() { return _armor; }

    bool canAct() { return _ap > 0; }
  }

  void passPhase() {
    _evade = baseEvade;
    _armor = baseArmor;
  }

  auto getAction(int num) {
    assert(num == 1 || num == 2, "action number %d is not valid".format(num));
    return (num == 1) ? action1 : action2;
  }

  void consumeAp(int amount) {
    assert(amount <= _ap, "tried to consume %d ap when only %d available".format(amount, _ap));
    _ap -= amount;
  }

  void dealDamage(int amount) {
    _hp = max(0, hp - amount);
    _sprite.flash(damageFlashTime, damageFlashColor);
    _damageSound.play();
  }

  void dodgeAttack() {
    assert(_evade > 0, "unit %s should not be evading with evade = %d".format(name, _evade));
    _evade -= 1;
    _sprite.flash(dodgeFlashTime, dodgeFlashColor);
  }

  bool canUseAnyAction(Tile target) {
    return canUseAction(1, target) || canUseAction(2, target);
  }

  bool canUseAnyAction(Unit unit) {
    return canUseAnyAction(unit.tile);
  }

  bool canUseAction(int num, Tile target) {
    auto action = getAction(num);
    if (action.apCost > ap) { return false; }
    int dist = tile.distance(target);
    bool inRange = dist <= action.maxRange && dist >= action.minRange;
    auto other = cast(Unit) target.entity;
    final switch (action.target) with (UnitAction.Target) {
      case enemy:
        return other !is null && other.team != team && inRange;
      case ground:
        return inRange;
      case ally:
        return other !is null && other.team == team && inRange;
      case self:
        return other !is null && other == this;
    }
  }

  void playAnimation(string animationKey, Animation.Action onAnimationEnd = null) {
    auto idle = delegate() {
      _sprite = new Animation(_key, "idle", Animation.Repeat.loop);
      if (onAnimationEnd !is null) { onAnimationEnd(); }
    };
    _sprite = new Animation(_key, animationKey, Animation.Repeat.no, idle);
  }

  auto getActionAnimation(int actionNum) {
    assert(actionNum == 1 || actionNum == 2, "%d is not a valid action number".format(actionNum));
    return new Animation(_key, "effect%d".format(actionNum));
  }

  override void update(float time) {
    if (canAct) { super.update(time); } // only animate sprite if ap > 0
  }

  private:
  Tile _tile;
  int _hp, _ap;
  int _evade, _armor; // current evade and armor stats
  const string _key;
  SoundSample _damageSound;
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
    transform
  }

  enum Special {
    pierce,  /// ignore armor
    precise, /// ignore evasion
    blitz,   /// cannot be countered
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

private:
UnitData[string] _data;

static this() {
  onInit({ _data = Paths.unitData.readJSON!(UnitData[string]); });
}
