module model.trap;

import std.string : format;
import dau.all;
import model.unitaction;

private enum {
  spriteFormat = "%s_trap",
  soundFormat = "%s-trap",
  effectDepth = 6,
}

class Trap : Entity {
  const int team;
  const UnitAction effect;
  const string key;

  this(string key, Vector2i pos, int team, const UnitAction effect) {
    auto sprite = new Animation(spriteFormat.format(key), "idle", Animation.Repeat.loop);
    super(pos, sprite, "trap");
    this.team = team;
    this.effect = effect;
    this.key = key;
  }

  auto getTriggerAnimation(Animation.Action onEnd) {
    auto anim = new Animation(spriteFormat.format(key), "trigger", Animation.Repeat.no, onEnd);
    anim.depth = effectDepth;
    return anim;
  }

  auto getTriggerSound() {
    return new SoundSample(soundFormat.format(key));
  }
}
