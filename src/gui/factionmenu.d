module gui.factionmenu;

import std.string, std.algorithm;
import dau.all;
import model.all;

private enum iconFmt = "icon_%s";

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
    addChild(new TextBox(data.child["text"], faction.name, data["nameOffset"].parseVector!int));
    Vector2i spriteOffset = data["spritesOffset"].parseVector!int;
    foreach(unitKey ; faction.standardUnitKeys) {
      auto iconData = getGUIData(iconFmt.format(unitKey));
      auto icon = addChild(new Icon(iconData, spriteOffset));
      icon.animation.stop();
      spriteOffset.x += icon.width;
    }
  }

  override void setSelected(bool val) {
    super.setSelected(val);
    foreach(icon ; childrenOfType!Icon) {
      if (val) {
        icon.animation.start();
      }
      else {
        icon.animation.stop();
      }
    }
  }
}
