module gui.battleselectionscreen;

import std.algorithm, std.range, std.file, std.path, std.array;
import dau.all;
import model.all;
import gui.factionmenu;
import battle.battle;
import title.title;
import title.state.showtitle;

enum mapFormat = Paths.mapDir ~ "/%s.json";

/// bar that displays progress as discrete elements (pips)
class BattleSelectionScreen : GUIElement {
  this(Title title) {
    super(getGUIData("selectBattle"), Vector2i.zero);

    auto mapPaths = Paths.mapDir.dirEntries("*.json", SpanMode.shallow);
    auto mapNames = mapPaths.map!(x => x.baseName(".json"));

    _startButton = new Button(data.child["startButton"], &startBattle);
    _startButton.enabled = false;

    // map an faction selections
    auto mapOffset          = data["mapSelectOffset"].parseVector!int;
    auto selfFactionOffset  = data["selfFactionOffset"].parseVector!int;
    auto otherFactionOffset = data["otherFactionOffset"].parseVector!int;

    _playerFactionMenu = new FactionMenu(selfFactionOffset, &selectPlayerFaction);
    _pcFactionMenu     = new FactionMenu(otherFactionOffset, &selectPCFaction);
    _mapSelector       = new StringSelection(getGUIData("selectMap"), mapOffset, mapNames.array);
    addChildren(_startButton, _playerFactionMenu, _pcFactionMenu, _mapSelector);

    _messageBox = new MessageBox(data.child["messageBox"]);
    _messageInput = new TextInput(data.child["messageInput"], &postMessage);
    addChildren(_messageBox, _messageInput);

    addChild(new Button(data.child["backButton"], () => title.states.setState(new ShowTitle)));

    addChildren!TextBox("titleText", "subtitle");
  }

  private:
  FactionMenu _playerFactionMenu, _pcFactionMenu;
  StringSelection _mapSelector;
  Button _startButton;
  MessageBox _messageBox;
  TextInput _messageInput;

  void selectPlayerFaction(Faction faction) {
    if (_pcFactionMenu.selection == faction) {
      _pcFactionMenu.setSelection(allFactions.find!(x => x != faction).front);
    }
    _startButton.enabled = _pcFactionMenu.selection !is null;
  }

  void selectPCFaction(Faction faction) {
    if (_playerFactionMenu.selection == faction) {
      _playerFactionMenu.setSelection(allFactions.find!(x => x != faction).front);
    }
    _startButton.enabled = _playerFactionMenu.selection !is null;
  }

  void startBattle() {
    auto playerFaction = _playerFactionMenu.selection;
    auto pcFaction = _pcFactionMenu.selection;
    auto mapName = _mapSelector.selection;
    setScene(new Battle(mapName, playerFaction, pcFaction));
  }

  void backToMenu() {
  }

  void postMessage(string text) {
  }
}
