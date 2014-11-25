module gui.hostscreen;

import std.string, std.conv;
import dau.all;
import net.all;
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

/// screen to host a network game
class HostScreen : GUIElement {
  this(Title title) {
    super(getGUIData("hostScreen"), Vector2i.zero);
    _title = title;

    addChildren!TextBox("title", "subtitle", "portLabel");
    addChild(new Button(data.child["back"], &backButton));

    _hostButton = new Button(data.child["hostGame"], &hostGame);
    _messageBox = new MessageBox(data.child["messageBox"]);
    _messageInput = new TextInput(data.child["messageInput"], &postMessage);

    _portInput = new TextInput(data.child["portInput"]);
    addChildren(_hostButton, _messageBox, _messageInput, _portInput);
  }

  override void update(float time) {
    if (_server !is null) {
      if (_client is null) {
        _client = _server.waitForClientConnection();
        if (_client !is null) {
          _messageBox.postMessage("client connected!", PostColor.note);
        }
      }
      else {
        NetworkMessage msg;
        bool gotSomething = _client.receive(msg);
        if (gotSomething) {
          processMessage(msg);
        }
      }
    }
  }

  private:
  Title _title;
  TextInput _portInput, _messageInput;
  MessageBox _messageBox;
  Button _hostButton;
  NetworkServer _server;
  NetworkClient _client;

  void processMessage(NetworkMessage msg) {
    switch (msg.type) with (NetworkMessage.Type) {
      case closeConnection:
        _messageBox.postMessage("Client left", PostColor.error);
        cancelHost();
        break;
      case chat:
        _messageBox.postMessage(msg.chat.text.dup, PostColor.other);
        break;
      default:
    }
  }

  void backButton() {
    cancelHost();
    _title.states.setState(new ShowTitle);
  }

  void hostGame() {
    if (_portInput.isValid) {
      _hostButton.text = "Cancel";
      _hostButton.action = &cancelHost;
      auto post = "Hosting on port %s".format(_portInput.text);
      _messageBox.postMessage(post, PostColor.note);
      _server = new NetworkServer(_portInput.text.to!ushort);
    }
    else {
      auto post = "%s is not a valid port".format(_portInput.text);
      _messageBox.postMessage(post, PostColor.error);
    }
  }

  void cancelHost() {
    _hostButton.text = "Host Game";
    _hostButton.action = &hostGame;
    if (_client !is null) {
      _client.send(NetworkMessage.makeCloseConnection);
      _client.close();
      _client = null;
    }
    if (_server !is null) {
      _server.close();
      _server = null;
    }
    _messageBox.postMessage("Connection closed", PostColor.error);
  }

  void postMessage(string message) {
    _messageBox.postMessage(PostFormat.self.format(message), PostColor.self);
    if (_client !is null) {
      _client.send(NetworkMessage.makeChat(message));
    }
    _messageInput.text = "";
  }
}
