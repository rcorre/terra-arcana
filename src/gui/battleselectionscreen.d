module gui.battleselectionscreen;

import std.algorithm, std.range, std.file, std.path, std.array;
import dau.all;
import net.all;
import model.all;
import gui.factionmenu;
import battle.battle;
import title.title;
import title.state.showtitle;

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
    this.isHost = isHost || client is null; // if singleplayer, default to host

    _startButton = new Button(data.child["startButton"], &beginBattle);
    _startButton.enabled = false;

    // map an faction selections
    auto selfFactionOffset  = data["selfFactionOffset"].parseVector!int;
    auto otherFactionOffset = data["otherFactionOffset"].parseVector!int;

    _playerFactionMenu = new FactionMenu(selfFactionOffset, &selectPlayerFaction);
    bool canPickOtherFaction = client is null;
    _otherFactionMenu  = new FactionMenu(otherFactionOffset, &selectOtherFaction,
        canPickOtherFaction);
    addChildren(_startButton, _playerFactionMenu, _otherFactionMenu);

    _messageBox = new MessageBox(data.child["messageBox"]);
    _messageInput = new TextInput(data.child["messageInput"], &postMessage);
    addChildren(_messageBox, _messageInput);

    addChild(new Button(data.child["backButton"], &backToMenu));

    addChildren!TextBox("titleText", "subtitle");
    auto levels = Paths.mapDir.dirEntries(SpanMode.shallow).map!(x => x.baseName).array;
    _difficultySelector = new StringSelection(data.child["difficulty"], levels, &setDifficulty);
    addChild(_difficultySelector);
    setDifficulty(levels.front);
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
  StringSelection _mapSelector, _difficultySelector;
  Button _startButton;
  MessageBox _messageBox;
  TextInput _messageInput;
  NetworkClient _client;
  Title _title;

  @property bool canStartGame() {
    return isHost && 
      _playerFactionMenu.selection !is null && 
      _otherFactionMenu.selection !is null;
  }

  void setDifficulty(string difficulty) {
    if (_mapSelector !is null) { _mapSelector.active = false; }
    auto dir = buildPath(Paths.mapDir, difficulty);
    auto mapPaths = dir.dirEntries("*.json", SpanMode.shallow);

    auto mapNames = mapPaths.map!(x => x.baseName(".json")).array;
    auto mapPos  = data["mapSelectOffset"].parseVector!int;
    _mapSelector = new StringSelection(getGUIData("selectMap"), mapPos, mapNames, &selectMap);
    addChild(_mapSelector);
  }

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
    _startButton.enabled = canStartGame;
  }

  void selectOtherFaction(Faction faction) {
    if (_playerFactionMenu.selection == faction) {
      _playerFactionMenu.setSelection(allFactions.find!(x => x != faction).front);
    }
    _startButton.enabled = canStartGame;
  }

  void beginBattle() {
    auto playerFaction = _playerFactionMenu.selection;
    auto otherFaction = _otherFactionMenu.selection;
    if (isHost && _client !is null) { 
      _client.send(NetworkMessage(NetworkMessage.Type.startBattle)); 
    }
    auto diff = _difficultySelector.selection;
    auto map = _mapSelector.selection;
    auto path = buildPath(Paths.mapDir, diff, map ~ ".json");
    setScene(new Battle(path, playerFaction, otherFaction, _client, isHost));
  }

  void backToMenu() {
    if (_client !is null) {
      _client.send(NetworkMessage.makeCloseConnection());
    }
    _title.states.popState();
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
