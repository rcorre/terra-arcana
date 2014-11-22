module gui.hostscreen;

import dau.all;
import model.all;
import battle.battle;
import title.title;
import title.state.showtitle;

/// screen to host a network game
class HostScreen : GUIElement {
  this(Title title) {
    super(getGUIData("hostScreen"), Vector2i.zero);
    _title = title;

    addChild(new TextBox(data.child["title"]));
    addChild(new TextBox(data.child["subtitle"]));
    addChild(new Button(data.child["back"], &backButton));

    _portInput = new TextInput(data.child["portInput"]);
    addChild(_portInput);
  }

  private:
  Title _title;
  TextInput _portInput;

  void backButton() {
    _title.states.setState(new ShowTitle);
  }
}
