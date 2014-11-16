module gui.factionmenu;

import std.string;
import std.conv;
import dau.all;
import model.all;

private enum {
  iconFmt = "icon_%s"
}

/// bar that displays progress as discrete elements (pips)
class FactionMenu : Menu!(Faction, FactionButton) {
  this(Vector2i offset, FactionButton.Action onClick) {
    auto menuData = getGUIData("factionMenu");
    super(menuData, offset, onClick);
    auto buttonData = data.child["factionButton"];
    foreach(faction ; allFactions()) {
      bool enabled = true;
      addEntry(buttonData, faction, enabled);
    }
  }
}

class FactionButton : MenuButton!Faction {
  this(GUIData data, Faction faction, Vector2i pos, Action onClick, bool enabled) {
    super(data, faction, pos, onClick, enabled);
    /*
    addChild(new TextBox(data.child["text"], unit.name, data["nameOffset"].parseVector!int));
    addChild(new TextBox(data.child["text"], unit.deployCost, data["costOffset"].parseVector!int));
    auto spriteOffset = data["spriteOffset"].parseVector!int;
    auto iconData = getGUIData(iconFmt.format(unitKey));
    addChild = new Icon(iconData, spriteOffset);
    */
  }
}
