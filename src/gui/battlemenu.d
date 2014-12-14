module gui.battlemenu;

import dau.all;
import model.all;
import title.title;
import battle.battle;
import battle.state.showinstructions;
import battle.state.showpreferences;

class BattleMenu : GUIElement {
  alias Action = void delegate();
  this(Battle battle) {
    super(getGUIData("battleMenu"));

    addChild(new TextBox(data.child["title"]));

    addChild(new Button(data.child["return"], { battle.states.popState(); }));
    addChild(new Button(data.child["surrender"], { setScene(new Title); }));

    auto showPreferences  = { battle.states.pushState(new ShowPreferences); };
    auto showInstructions = { battle.states.pushState(new ShowInstructions); };

    addChild(new Button(data.child["instructions"], showInstructions));
    addChild(new Button(data.child["preferences"], showPreferences));
  }
}
