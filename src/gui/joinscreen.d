module gui.joinscreen;

import dau.all;
import model.all;
import battle.battle;
import title.title;
import title.state.showtitle;

/// screen to join a network game
class JoinScreen : GUIElement {
  this(Title title) {
    super(getGUIData("joinScreen"), Vector2i.zero);
    _title = title;

    addChildren!TextBox("title", "subtitle", "portLabel", "ipLabel");
    addChild(new Button(data.child["back"], &backButton));

    _ipInput = new TextInput(data.child["ipInput"]);
    addChild(_ipInput);

    _portInput = new TextInput(data.child["portInput"]);
    addChild(_portInput);
  }

  private:
  Title _title;
  TextInput _ipInput, _portInput;
  void backButton() {
    _title.states.setState(new ShowTitle);
  }
}
