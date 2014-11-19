module gui.titlescreen;

import dau.all;
import model.all;
import title.title;
import title.state.selectbattle;

/// bar that displays progress as discrete elements (pips)
class TitleScreen : GUIElement {
  this(Title title) {
    super(getGUIData("titleScreen"), Vector2i.zero);
    addChild(new TextBox(data.child["titleText"]));
    addChild(new TextBox(data.child["versionText"]));

    addChild(new Button(data.child["startSinglePlayer"], &singlePlayerButton));
    addChild(new Button(data.child["startNetwork"], &networkButton));
    addChild(new Button(data.child["preferences"], &preferencesButton));
    addChild(new Button(data.child["credits"], &creditsButton));
    addChild(new Button(data.child["exit"], &exitButton));

    _title = title;
  }

  private:
  Title _title;
  void singlePlayerButton() {
    _title.states.setState(new SelectBattle);
  }

  void networkButton() {
  }

  void preferencesButton() {
  }

  void creditsButton() {
  }

  void exitButton() {
    shutdownGame();
  }
}
