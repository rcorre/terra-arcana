module gui.deploymenu;

import std.string;
import std.conv;
import dau.all;
import model.all;

private enum {
  iconFmt = "icon_%s"
}

/// bar that displays progress as discrete elements (pips)
class DeployMenu : Menu!(string, DeployButton) {
  this(const Faction faction, Vector2i offset, DeployButton.Action onClick, int cp) {
    auto menuData = getGUIData("deployMenu");
    super(menuData, offset, onClick);
    auto buttonData = data.child["deployButton"];
    foreach(key ; faction.standardUnitKeys) {
      bool enabled = getUnitData(key).deployCost <= cp;
      addEntry(buttonData, key, enabled);
    }
  }
}

class DeployButton : MenuButton!string {
  this(GUIData data, string unitKey, Vector2i pos, Action onClick, bool enabled) {
    super(data, unitKey, pos, onClick, enabled);
    auto unit = getUnitData(unitKey);
    addChild(new TextBox(data.child["text"], unit.name, data["nameOffset"].parseVector!int));
    addChild(new TextBox(data.child["text"], unit.deployCost, data["costOffset"].parseVector!int));
    auto spriteOffset = data["spriteOffset"].parseVector!int;
    auto iconData = getGUIData(iconFmt.format(unitKey));
    addChild = new Icon(iconData, spriteOffset);
  }
}

Font _font;

static this() {
  onInit({ _font = Font("Mecha", 20); });
}
