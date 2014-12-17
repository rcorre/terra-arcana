module gui.battlepopup;

import std.string, std.conv;
import dau.all;
import model.unitaction;

private enum string[UnitAction.Effect.max + 1] formats = [
  UnitAction.Effect.damage     : "hp - %d",
  UnitAction.Effect.heal       : "hp + %d",
  UnitAction.Effect.evade      : "evade + %d",
  UnitAction.Effect.armor      : "armor + %d",
  UnitAction.Effect.toxin      : "toxin (%d)",
  UnitAction.Effect.slow       : "slow (%d)",
  UnitAction.Effect.stun       : "stun (%d)",
];

class BattlePopup : GUIElement {
  enum Type : string {
    miss = "miss! (%d -> %d)",
    cover = "cover (%d -> %d)",
    toxicDamage = "toxin (%d -> %d)",
    notEnoughAp = "not enough AP"
  }

  this(Vector2i pos, UnitAction.Effect effect, int value) {
    super(getGUIData("battlePopup"), pos);
    _duration = data["duration"].to!float;
    _velocity = data["velocity"].parseVector!float;
    string text = formats[effect].format(value);
    addChild(new TextBox(data.child[effect.to!string], text));
  }

  this(T...)(Vector2i pos, Type type, T args) {
    super(getGUIData("battlePopup"), pos);
    _duration = data["duration"].to!float;
    _velocity = data["velocity"].parseVector!float;
    string text = type.format(args);
    string key = type.to!string;
    addChild(new TextBox(data.child[key], text));
  }

  override void update(float time) {
    super.update(time);
    area.center = area.center + cast(Vector2i) (_velocity * time);
    _duration -= time;
    if (_duration <= 0) {
      active = false;
    }
  }

  private float _duration;
  private Vector2f _velocity;
}
