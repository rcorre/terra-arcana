module gui.unitpreview;

import dau.geometry.all;
import dau.graphics.all;
import dau.gui.all;
import model.all;

/// bar that displays progress as discrete elements (pips)
class UnitPreview : DynamicGUIElement {
  this(Unit unit) {
    super(getGUIData("unitPreview"));

    _name = addChild(new TextBox(data.child["name"], unit.name));
    _hpBar = addChild(new PipBar(data.child["hpBar"], unit.maxHp));
    _apBar = addChild(new PipBar(data.child["apBar"], unit.maxAp));

    refresh(unit);
  }

  void refresh(Unit unit) {
    _name.text = unit.name;
    _hpBar.setVal(unit.hp);
    _apBar.setVal(unit.ap);
    transitionActive = true;
  }

  void hide() {
    transitionActive = false;
  }

  override void update(float time) {
    super.update(time);
    if (!transitionActive && transitionAtStart) {
      active = false;
    }
  }

  private:
  TextBox _name;
  PipBar _hpBar, _apBar;
  bool _hiding;
}
