module battle.ai.decision;

import model.all;

abstract class AIDecision {
  enum Type {
    deploy,
    move,
    action,
  }

  const float score;
  const Type type;

  this(Type type, float score) {
    this.type = type;
    this.score = score;
  }
}

class MoveDecison : AIDecision {
  Unit unit;
  Tile[] path;

  this(Unit unit, Tile[] path, float score) {
    super(Type.move, score);
    this.unit = unit;
    this.path = path;
  }
}

class ActDecison : AIDecision {
  Unit actor;
  Tile target;
  Tile[] movePath;
  int actionNum;

  this(Unit actor, Tile[] movePath, Tile target, int actionNum, float score) {
    super(Type.action, score);
    this.actor = actor;
    this.movePath = movePath;
    this.target = target;
    this.actionNum = actionNum;
  }
}

class DeployDecison : AIDecision {
  string unitKey;
  Tile location;

  this(string unitKey, Tile location, float score) {
    super(Type.deploy, score);
    this.unitKey = unitKey;
    this.location = location;
  }
}
