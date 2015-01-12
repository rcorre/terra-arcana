module gui.factionmenu;

import std.array;
import dau.all;
import model.all;

/// bar that displays progress as discrete elements (pips)
class FactionMenu : StringSelection {
  this(GUIData data, Action onClick, bool enabled = true) {
    string[] entries = allFactions.map!(x => x.name).array;
    super(data, entries, onClick);
  }
}
