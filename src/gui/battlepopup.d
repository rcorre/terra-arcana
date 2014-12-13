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
  this(Vector2i pos, UnitAction.Effect effect, int value) {
    super(getGUIData("battlePopup"), pos);
    _duration = data["duration"].to!float;
    _velocity = data["velocity"].parseVector!float;
    string text = formats[effect].format(value);
    addChild(new TextBox(data.child[effect.to!string], text));
  }

  static BattlePopup evadeMessage(Vector2i pos) {
    return new BattlePopup(pos);
  }

  private this(Vector2i pos) {
    super(getGUIData("battlePopup"), pos);
    _duration = data["duration"].to!float;
    _velocity = data["velocity"].parseVector!float;
    string text = "miss!";
    addChild(new TextBox(data.child["miss"], text));
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
