module model.unit;

import std.string : format;
import std.algorithm : canFind, max;
import dau.all;
import model.tile;
import model.unitaction;

enum Team {
  player,
  pc
}

private enum {
  damageFlashColor = Color.red,
  healFlashColor = Color.green,
  dodgeFlashColor = Color(1, 1, 1, 0.5),
  flashTime = 0.2f,
  actionSoundFormat = "%s-action%d",
  // ap loss effect
  shakeOffset = Vector2i(4, 0),
  shakeSpeed = 30,
  shakeRepetitions = 4,
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
    _healSound   = new SoundSample("heal");
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

  void endTurn() {
  }

  void startTurn() {
    _ap = maxAp;
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
    _sprite.flash(flashTime, damageFlashColor);
    _damageSound.play();
  }

  void damageAp(int amount) {
    _ap -= amount; // TODO: negative ap handling
    _sprite.shake(shakeOffset, shakeSpeed, shakeRepetitions);
  }

  void restoreHealth(int amount) {
    _hp = min(maxHp, hp + amount);
    _sprite.flash(flashTime, healFlashColor);
    _healSound.play();
  }

  void adjustEvade(int amount) {
    _evade = max(0, _evade + amount);
  }

  void adjustArmor(int amount) {
    _armor = max(0, _armor + amount);
  }

  void dodgeAttack() {
    assert(_evade > 0, "unit %s should not be evading with evade = %d".format(name, _evade));
    _evade -= 1;
    _sprite.flash(flashTime, dodgeFlashColor);
  }

  /// return first action useable on target, or null if no useable actions
  int firstUseableAction(Tile target) {
    if      (canUseAction(1, target)) { return 1; }
    else if (canUseAction(2, target)) { return 2; }
    else                              { return 0; }
  }

  int firstUseableAction(Unit unit) {
    return firstUseableAction(unit.tile);
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

  auto getActionSound(int actionNum) {
    assert(actionNum == 1 || actionNum == 2, "%d is not a valid action number".format(actionNum));
    return new SoundSample(actionSoundFormat.format(_key, actionNum));
  }

  override void update(float time) {
    if (canAct) { super.update(time); } // only animate sprite if ap > 0
  }

  private:
  Tile _tile;
  int _hp, _ap;
  int _evade, _armor; // current evade and armor stats
  const string _key;
  SoundSample _damageSound, _healSound;
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

private:
UnitData[string] _data;

static this() {
  onInit({ _data = Paths.unitData.readJSON!(UnitData[string]); });
}
