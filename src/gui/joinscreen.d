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

  override void update(float time) {
    if (_client !is null) {
      NetworkMessage msg;
      bool gotSomething = _client.receive(msg);
      if (gotSomething) {
        processMessage(msg);
      }
    }
  }

  private:
  Title _title;
  TextInput _ipInput, _portInput, _messageInput;
  Button _joinButton;
  NetworkClient _client;
  MessageBox _messageBox;

  void processMessage(NetworkMessage msg) {
    switch (msg.type) with (NetworkMessage.Type) {
      case closeConnection:
        _messageBox.postMessage("Host closed Connection", PostColor.error);
        cancelJoin();
        break;
      case chat:
        _messageBox.postMessage(cast(string) msg.chat.text, PostColor.other);
        break;
      default:
    }
  }

  void backButton() {
    cancelJoin();
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
    if (_client !is null) { 
      _client.send(NetworkMessage.makeCloseConnection);
      _client.close(); 
      _client = null;
    }
  }

  void postMessage(string message) {
    _messageBox.postMessage(PostFormat.self.format(message), PostColor.self);
    _messageInput.text = "";
  }
}
