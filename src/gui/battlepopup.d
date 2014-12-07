module gui.battlepopup;

import std.string;
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

private enum string[UnitAction.Effect.max + 1] colors = [
  UnitAction.Effect.damage     : "1,0,0",
  UnitAction.Effect.heal       : "0,1,0",
  UnitAction.Effect.evade      : "0,0,1",
  UnitAction.Effect.armor      : "0,0,1",
  UnitAction.Effect.toxin      : "0,1,0",
  UnitAction.Effect.slow       : "1,0,0",
  UnitAction.Effect.stun       : "1,0,0",
];

private enum velocity = Vector2i(0, -120);

class BattlePopup : TextBox {

  this(Vector2i pos, UnitAction.Effect effect, int value) {
    auto data = getGUIData("battlePopup");
    data["textColor"] = colors[effect];
    string text = formats[effect].format(value);
    super(data, text, pos);
  }

  static BattlePopup evadeMessage(Vector2i pos) {
    return new BattlePopup(pos);
  }

  private this(Vector2i pos) {
    auto data = getGUIData("battlePopup");
    data["textColor"] = "1,1,1";
    string text = "miss (evasion - 1)";
    super(data, text, pos);
  }

  override void update(float time) {
    super.update(time);
    area.center = area.center + cast(Vector2i) (velocity * time);
  }
}
