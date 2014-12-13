module gui.unitpreview;

import dau.geometry.all;
import dau.graphics.all;
import dau.gui.all;
import model.all;

/// bar that displays progress as discrete elements (pips)
class UnitPreview : GUIElement {
  this(Unit unit) {
    super(getGUIData("unitPreview"));

    _hpBar = addChild(new PipBar(data.child["hpBar"], unit.maxHp));
    _apBar = addChild(new PipBar(data.child["apBar"], unit.maxAp));

    refresh(unit);
  }

  void refresh(Unit unit) {
    _hpBar.setVal(unit.hp);
    _apBar.setVal(unit.ap);
  }

  private:
  PipBar _hpBar, _apBar;
}
