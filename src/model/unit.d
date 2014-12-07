module model.unit;

import std.string : format;
import std.algorithm : canFind, max;
import dau.all;
import model.tile;
import model.unitaction;

private enum {
  damageFlashColor = Color.red,
  healFlashColor = Color.green,
  dodgeFlashColor = Color(1, 1, 1, 0.5),
  toxinFlashColor = Color(0.5, 0, 0.5),
  flashTime = 0.2f,
  actionSoundFormat = "%s-action%d",
  // ap loss effect
  shakeOffset = Vector2i(4, 0),
  shakeSpeed = 30,
  shakeRepetitions = 4,
}

class Unit : Entity {
  const int team;
  const UnitData data;
  const string key;
  alias data this;

  this(string key, Tile tile, int team) {
    auto sprite = new Animation(key, "idle", Animation.Repeat.loop);
    super(tile.center, sprite, "unit");
    assert(key in _data, "no unit data matches key "  ~ key);
    data = _data[key];
    this.tile = tile;
    _hp = data.maxHp;
    _ap = data.maxHp;
    this.team = team;
    this.key = key;
    _damageSound   = new SoundSample("damage");
    _noDamageSound = new SoundSample("no-damage");
    _healSound     = new SoundSample("heal");
    _evadeSound    = new SoundSample("evade");
    _destroySound  = new SoundSample("destroy-unit");
    startTurn();
  }

  @property {
    auto tile() { return _tile; }
    void tile(Tile newTile) {
      if (newTile == _tile) { return; }
      assert(newTile.entity is null, "cannot place %s on tile %d,%d which already has entity"
          .format(name, newTile.row, newTile.col));
      if (tile !is null) {
        tile.entity = null; // remove self from previous tile
      }
      _tile = newTile;
      _tile.entity = this;
      center = tile.center;
      // reset cover bonus unless have guerilla trait and on tile with cover
      _coverBonus = (hasTrait(UnitData.Trait.guerilla) && newTile.cover > 0) ? 1 : 0;
    }

    int hp() { return _hp; }
    int ap() { return _ap; }

    int evade() { return _evade + _coverBonus; }
    int armor() { return _armor; }
    int toxin() { return _toxin; }
    int slow()  { return _slow; }

    bool canAct()   { return _ap > 0 && isAlive; }
    bool isAlive()  { return _hp > 0; }
    bool isSlowed() { return _slow > 0; }
    bool isToxic()  { return _toxin > 0; }
  }

  void endTurn() {
    _slow = max(0, _slow - 1);
    if (!hasTrait(UnitData.Trait.flight)) { // no cover bonus for flying units
      _coverBonus = min(_coverBonus + 1, tile.cover);
    }
  }

  void startTurn() {
    _ap = min(_ap + maxAp, maxAp);
    _evade = baseEvade;
    _armor = baseArmor;
    if (_toxin > 0) {
      _hp = max(0, hp - 1);
      _sprite.flash(flashTime, toxinFlashColor);
      _damageSound.play();
      --_toxin;
    }
  }

  auto getAction(int num) {
    if      (num == 1) { return action1; }
    else if (num == 2) { return action2; }
    else               { return null; }
  }

  void consumeAp(int amount) {
    assert(amount <= _ap, "tried to consume %d ap when only %d available".format(amount, _ap));
    _ap -= amount;
  }

  /// deal damage, returns amount of damage dealt
  int dealDamage(int amount, bool ignoreArmor) {
    amount -= ignoreArmor ? 0 : armor;
    if (amount > 0) {
      _hp = max(0, hp - amount);
      _sprite.flash(flashTime, damageFlashColor);
      _damageSound.play();
    }
    else { // no damage
      _noDamageSound.play();
    }
    return amount;
  }

  void damageAp(int amount) {
    _ap = max(_ap - amount, -maxAp);
    _sprite.shake(shakeOffset, shakeSpeed, shakeRepetitions);
  }

  void applyToxin(int amount) {
    _toxin += amount;
    _sprite.flash(flashTime, toxinFlashColor);
  }

  void applySlow(int amount) {
    _slow += amount;
    _sprite.shake(shakeOffset, shakeSpeed, shakeRepetitions);
  }

  void restoreHealth(int amount) {
    if (_toxin > 0) {amount = max(0, _toxin);
      int toxinReduce = min(_toxin, amount);
      _toxin -= toxinReduce;
      amount -= toxinReduce;
    }
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
    if (_coverBonus > 0) {
      --_coverBonus;
    }
    else {
      assert(_evade > 0, "unit %s should not be evading with evade = %d".format(name, _evade));
      --_evade;
    }
    _sprite.flash(flashTime, dodgeFlashColor);
    _evadeSound.play();
  }

  /// return first action useable on target, or null if no useable actions
  int firstUseableAction(Tile target) {
    if      (canUseAction(1, target)) { return 1; }
    else if (canUseAction(2, target)) { return 2; }
    else                              { return 0; }
  }

  int firstUseableActionFrom(Tile target, Tile position, int apLeft) {
    if      (canUseActionFrom(1, target, position, apLeft)) { return 1; }
    else if (canUseActionFrom(2, target, position, apLeft)) { return 2; }
    else                                                    { return 0; }
  }

  int firstUseableAction(Unit unit) {
    return firstUseableAction(unit.tile);
  }

  bool canUseAction(int num, Unit unit) {
    return canUseAction(num, unit.tile);
  }

  bool canUseAction(int num, Tile target) {
    return canUseActionFrom(num, target, tile, ap);
  }

  /// return true if can use action num from position on target
  bool canUseActionFrom(int num, Tile target, Tile position, int apLeft) {
    auto action = getAction(num);
    if (action.apCost > apLeft) { return false; }
    int dist = position.distance(target);
    bool inRange = dist <= action.maxRange && dist >= action.minRange;
    auto other = cast(Unit) target.entity;
    final switch (action.target) with (UnitAction.Target) {
      case enemy:
        return other !is null && other.team != team && inRange;
      case burst:
      case line:
        return inRange;
      case ally:
        return other !is null && other.team == team && inRange;
      case self:
        return other !is null && other == this;
      case trap:
        return inRange && target.trap is null;
    }
  }

  void playAnimation(string animationKey, Animation.Action onAnimationEnd = null) {
    auto idle = delegate() {
      _sprite = new Animation(key, "idle", Animation.Repeat.loop);
      if (onAnimationEnd !is null) { onAnimationEnd(); }
    };
    _sprite = new Animation(key, animationKey, Animation.Repeat.no, idle);
  }

  auto getActionAnimation(int actionNum) {
    assert(actionNum == 1 || actionNum == 2, "%d is not a valid action number".format(actionNum));
    return new Animation(key, "effect%d".format(actionNum));
  }

  auto getActionSound(int actionNum) {
    assert(actionNum == 1 || actionNum == 2, "%d is not a valid action number".format(actionNum));
    return new SoundSample(actionSoundFormat.format(key, actionNum));
  }

  int computeMoveCost(Tile tile) {
    auto other = cast(Unit) tile.entity;
    if (hasTrait(UnitData.Trait.flight)) { // flight costs 1 for all tiles
      return isSlowed ? 2 : 1;
    }
    if (other !is null && other.team != team) {
      return Tile.unreachable;
    }
    return tile.moveCost * (isSlowed ? 2 : 1);
  }

  void destroy(float fadeTime, Color[] fadeSpectrum) {
    tile.entity = null;
    sprite.fade(fadeTime, fadeSpectrum);
    _destroySound.play();
  }

  private:
  Tile _tile;
  int _hp, _ap;
  int _evade, _armor; // current evade and armor stats
  int _coverBonus;    // evasion granted by cover
  int _toxin, _slow;
  SoundSample _damageSound, _noDamageSound, _healSound, _evadeSound, _destroySound;

  @property auto animation() { return cast(Animation) _sprite; }

}

class UnitData {
  mixin JsonizeMe;

  enum Tier {
    basic,
    advanced,
    elite
  }

  enum Trait {
    guerilla, /// get immediate cover bonus upon entering tile with cover
    flight,   /// ignore most tile move costs
    warp,     /// ignore some tile move costs
  }

  @jsonize {
    string name;
    Tier tier;
    int maxHp;
    int maxAp;
    int baseArmor;
    int baseEvade;
    UnitAction action1, action2;
    Trait[] traits;
  }

  @property int deployCost() const {
    final switch (tier) with (Tier) {
      case basic:
        return 2;
      case advanced:
        return 3;
      case elite:
        return 4;
    }
  }

  bool hasTrait(Trait trait) const {
    return traits.canFind(trait);
  }
}

const(UnitData) getUnitData(string key) { return _data[key]; }

private:
UnitData[string] _data;

static this() {
  onInit({ _data = Paths.unitData.readJSON!(UnitData[string]); });
}
