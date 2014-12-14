module gui.battlemenu;

import dau.all;
import model.all;
import battle.battle;

class BattleMenu : GUIElement {
  alias Action = void delegate();
  this(Action returnButton, Action surrenderButton) {
    super(getGUIData("battleMenu"));

    addChild(new TextBox(data.child["title"]));

    addChild(new Button(data.child["return"], returnButton));
    addChild(new Button(data.child["surrender"], surrenderButton));

    addChild(new Button(data.child["instructions"], &showInstructions));
    addChild(new Button(data.child["preferences"], &showPreferences));
  }

  private:
  void showInstructions() {
  }

  void showPreferences() {
  }
}
