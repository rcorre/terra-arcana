module gui.battleselectionscreen;

import std.algorithm, std.range, std.file, std.path, std.array;
import dau.all;
import net.all;
import model.all;
import gui.factionmenu;
import battle.battle;
import title.title;
import title.state.showtitle;

private enum mapFormat = Paths.mapDir ~ "/%s.json";

private enum PostColor : Color {
  self = Color.blue,
  other = Color.green,
  error = Color.red,
  note = Color.black
}

private enum PostFormat : string {
  self  = "you: %s",
  other = "opponent: %s",
  error = "error: %s",
  note  = "system: %s",
  youChoseMap = "you chose map %s",
  otherChoseMap = "opponent chose map %s",
  youChoseFaction = "you chose faction %s",
  otherChoseFaction = "opponent chose faction %s",
}

/// bar that displays progress as discrete elements (pips)
class BattleSelectionScreen : GUIElement {
  const bool isHost;

  this(Title title, NetworkClient client = null, bool isHost = false) {
    super(getGUIData("selectBattle"), Vector2i.zero);

    _client = client;
    _title = title;
    this.isHost = isHost;

    auto mapPaths = Paths.mapDir.dirEntries("*.json", SpanMode.shallow);
    auto mapNames = mapPaths.map!(x => x.baseName(".json")).array;

    _startButton = new Button(data.child["startButton"], &beginBattle);
    _startButton.enabled = false;

    // map an faction selections
    auto mapOffset          = data["mapSelectOffset"].parseVector!int;
    auto selfFactionOffset  = data["selfFactionOffset"].parseVector!int;
    auto otherFactionOffset = data["otherFactionOffset"].parseVector!int;

    _playerFactionMenu = new FactionMenu(selfFactionOffset, &selectPlayerFaction);
    _otherFactionMenu  = new FactionMenu(otherFactionOffset, &selectOtherFaction);
    _mapSelector = new StringSelection(getGUIData("selectMap"), mapOffset, mapNames, &selectMap);
    addChildren(_startButton, _playerFactionMenu, _otherFactionMenu, _mapSelector);

    _messageBox = new MessageBox(data.child["messageBox"]);
    _messageInput = new TextInput(data.child["messageInput"], &postMessage);
    addChildren(_messageBox, _messageInput);

    addChild(new Button(data.child["backButton"], &backToMenu));

    addChildren!TextBox("titleText", "subtitle");
  }

  override void update(float time) {
    super.update(time);
    if (_client !is null) {
      NetworkMessage msg;
      bool gotSomething = _client.receive(msg);
      if (gotSomething) {
        processMessage(msg);
      }
    }
  }

  private:
  FactionMenu _playerFactionMenu, _otherFactionMenu;
  StringSelection _mapSelector;
  Button _startButton;
  MessageBox _messageBox;
  TextInput _messageInput;
  NetworkClient _client;
  Title _title;

  void processMessage(NetworkMessage msg) {
    switch (msg.type) with (NetworkMessage.Type) {
      case closeConnection:
        _messageBox.postMessage("Client left", PostColor.error);
        backToMenu();
        break;
      case chat:
        _messageBox.postMessage(PostFormat.other.format(msg.chat.text), PostColor.other);
        break;
      case chooseMap:
        string name = msg.chooseMap.name;
        auto note = PostFormat.otherChoseMap.format(name);
        _messageBox.postMessage(note, PostColor.note);
        _mapSelector.selection = name;
        break;
      case chooseFaction:
        string name = msg.chooseFaction.name;
        auto note = PostFormat.otherChoseFaction.format(name);
        _messageBox.postMessage(note, PostColor.note);
        auto faction = getFaction(name);
        _otherFactionMenu.setSelection(faction);
        selectOtherFaction(faction);
        break;
      case startBattle:
        beginBattle();
        break;
      default:
    }
  }

  void selectPlayerFaction(Faction faction) {
    if (_otherFactionMenu.selection == faction) {
      _otherFactionMenu.setSelection(allFactions.find!(x => x != faction).front);
    }
    if (_client !is null) {
      _client.send(NetworkMessage.makeChooseFaction(faction));
    }
    _startButton.enabled = isHost && _otherFactionMenu.selection !is null;
  }

  void selectOtherFaction(Faction faction) {
    if (_playerFactionMenu.selection == faction) {
      _playerFactionMenu.setSelection(allFactions.find!(x => x != faction).front);
    }
    _startButton.enabled = isHost && _playerFactionMenu.selection !is null;
  }

  void beginBattle() {
    auto playerFaction = _playerFactionMenu.selection;
    auto otherFaction = _otherFactionMenu.selection;
    auto mapName = _mapSelector.selection;
    if (isHost) { _client.send(NetworkMessage(NetworkMessage.Type.startBattle)); }
    setScene(new Battle(mapName, playerFaction, otherFaction, _client, isHost));
  }

  void backToMenu() {
    if (_client !is null) {
      _client.send(NetworkMessage.makeCloseConnection());
    }
    _title.states.setState(new ShowTitle);
  }

  void postMessage(string text) {
    _messageBox.postMessage(PostFormat.self.format(text), PostColor.self);
    _messageInput.text = "";
    if (_client !is null) {
      _client.send(NetworkMessage.makeChat(text));
    }
  }

  void selectMap(string mapName) {
    if (_client !is null) {
      _client.send(NetworkMessage.makeChooseMap(mapName));
    }
  }
}
