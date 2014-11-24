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

    addChildren!TextBox("title", "subtitle", "portLabel");
    addChild(new Button(data.child["back"], &backButton));

    _hostButton = new Button(data.child["hostGame"], &hostGame);
    _messageBox = new MessageBox(data.child["messageBox"]);
    _messageInput = new TextInput(data.child["messageInput"], &postMessage);

    _portInput = new TextInput(data.child["portInput"]);
    addChildren(_hostButton, _messageBox, _messageInput, _portInput);
  }

  private:
  Title _title;
  TextInput _portInput, _messageInput;
  MessageBox _messageBox;
  Button _hostButton;

  void backButton() {
    _title.states.setState(new ShowTitle);
  }

  void hostGame() {
    _hostButton.text = "Cancel";
    _hostButton.action = &cancelHost;
  }

  void cancelHost() {
    _hostButton.text = "Host Game";
    _hostButton.action = &hostGame;
  }

  void postMessage(string message) {
    _messageBox.postMessage(message);
    _messageInput.text = "";
  }
}
