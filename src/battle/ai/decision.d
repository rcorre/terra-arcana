module battle.ai.decision;

import dau.geometry.vector;
import model.all;

abstract class AIDecision {
  enum Type {
    deploy,
    move,
    action,
  }

  const float score;
  const Type type;

  /// point on map where decision will take place (for camera purposes)
  @property Vector2i decisionPoint();

  this(Type type, float score) {
    this.type = type;
    this.score = score;
  }
}

class MoveDecison : AIDecision {
  Unit unit;
  Tile[] path;

  override @property Vector2i decisionPoint() {
    return unit.center;
  }

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

  override @property Vector2i decisionPoint() {
    return actor.center;
  }

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

  override @property Vector2i decisionPoint() {
    return location.center;
  }

  this(string unitKey, Tile location, float score) {
    super(Type.deploy, score);
    this.unitKey = unitKey;
    this.location = location;
  }
}
