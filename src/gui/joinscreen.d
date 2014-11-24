module gui.joinscreen;

import std.conv;
import net.all;
import dau.all;
import model.all;
import battle.battle;
import title.title;
import title.state.showtitle;

private enum PostColor : Color {
  self  = Color.blue,
  other = Color.green,
  note  = Color.black,
  error = Color.red
}

private enum PostFormat : string {
  self  = "you: %s",
  other = "other: %s",
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
    _messageInput = new TextInput(data.child["messageInput"], &postMessage);

    addChildren(_joinButton, _ipInput, _portInput, _messageBox, _messageInput);
  }

  private:
  Title _title;
  TextInput _ipInput, _portInput, _messageInput;
  Button _joinButton;
  NetworkClient _client;
  MessageBox _messageBox;

  void backButton() {
    _title.states.setState(new ShowTitle);
  }

  void joinGame() {
    _joinButton.text = "Cancel";
    _joinButton.action = &cancelJoin;
    _client = new NetworkClient(_ipInput.text, _portInput.text.to!ushort);
  }

  void cancelJoin() {
    _joinButton.text = "Join Game";
    _joinButton.action = &joinGame;
  }

  void postMessage(string message) {
    _messageBox.postMessage(PostFormat.self.format(message), PostColor.self);
    _messageInput.text = "";
  }
}
