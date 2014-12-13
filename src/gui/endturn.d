module gui.endturn;

import dau.gui.all;

class EndTurnPopup : GUIElement {
  this() {
    super(getGUIData("endTurn"));
    addChildren!TextBox("mainText", "confirmText", "cancelText");
    addChildren!Icon("confirmIcon", "cancelIcon");
  }
}
