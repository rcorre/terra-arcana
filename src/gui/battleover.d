module gui.battleover;

import std.typecons;
import dau.gui.all;

class BattleOverPopup : GUIElement {
  this(Flag!"Victory" victory) {
    super(getGUIData("battleOver"));
    addChildren!TextBox(victory ? "victory" : "defeat");
    addChildren!TextBox("confirmText");
    addChildren!Icon("confirmIcon");
  }
}
