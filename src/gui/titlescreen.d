module gui.titlescreen;

import dau.all;
import model.all;
import title.title;
import title.state.selectbattle;
import title.state.editpreferences;
import title.state.showinstructions;
import title.state.hostgame;
import title.state.joingame;
import title.state.showcredits;

class TitleScreen : GUIElement {
  this(Title title) {
    super(getGUIData("titleScreen"), Vector2i.zero);
    addChild(new TextBox(data.child["titleText"]));
    addChild(new TextBox(data.child["versionText"]));

    addChild(new Button(data.child["singlePlayer"], &singlePlayerButton));
    addChild(new Button(data.child["hostGame"], &hostGame));
    addChild(new Button(data.child["joinGame"], &joinGame));
    addChild(new Button(data.child["preferences"], &preferencesButton));
    addChild(new Button(data.child["instructions"], &instructionsButton));
    addChild(new Button(data.child["credits"], &creditsButton));
    addChild(new Button(data.child["exit"], &exitButton));

    _title = title;
  }

  private:
  Title _title;
  void singlePlayerButton() {
    _title.states.setState(new SelectBattle);
  }

  void hostGame() {
    _title.states.setState(new HostGame);
  }

  void joinGame() {
    _title.states.setState(new JoinGame);
  }

  void instructionsButton() {
    _title.states.setState(new ShowInstructions);
  }

  void preferencesButton() {
    _title.states.setState(new EditPreferences);
  }

  void creditsButton() {
    _title.states.setState(new ShowCredits);
  }

  void exitButton() {
    shutdownGame();
  }
}
