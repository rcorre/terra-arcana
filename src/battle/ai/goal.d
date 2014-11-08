module battle.ai.goal;

import model.all;

struct AIGoal {
  enum Type {
    attack,
    aid,
    capture
  }

  this(Type type, Tile target, float priority) {
    this.type = type;
    this.target = target;
  }

  Type type;
  Tile target;
  float priority;

  @property auto targetUnit() { return cast(Unit) target.entity; }
}
