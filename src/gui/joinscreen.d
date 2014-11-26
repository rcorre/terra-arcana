module gui.joinscreen;

import std.conv;
import net.all;
import dau.all;
import model.all;
import battle.battle;
import title.title;
import title.state.showtitle;
import title.state.selectbattle;

private enum PostColor : Color {
  note  = Color.black,
  error = Color.red
}

private enum PostFormat : string {
  note  = "note: %s",
  error = "error: %s",
}

/// screen to join a network game
class JoinScreen : GUIElement {
  this(Title title) {
    super(getGUIData("joinScreen"), Vector2i.zero);
    _title = title;

    addChildren!TextBox("title", "subtitle", "portLabel", "ipLabel");
    addChild(new Button(data.child["back"], &backButton));

    _joinButton = new Button(data.child["joinButton"], &joinGame);
    _ipInput = new TextInput(data.child["ipInput"]);
    _portInput = new TextInput(data.child["portInput"]);

    _messageBox = new MessageBox(data.child["messageBox"]);

    addChildren(_joinButton, _ipInput, _portInput, _messageBox);
  }

  private:
  Title _title;
  TextInput _ipInput, _portInput;
  Button _joinButton;
  MessageBox _messageBox;

  void backButton() {
    _title.states.setState(new ShowTitle);
  }

  void joinGame() {
    try {
      auto client = new NetworkClient(_ipInput.text, _portInput.text.to!ushort);
      _title.states.setState(new SelectBattle(client, false));
    }
    catch(Exception ex) {
      _messageBox.postMessage(ex.msg, PostColor.error);
    }
  }
}
