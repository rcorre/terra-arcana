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
      auto playerOffset       = data["playerOffset"].parseVector!int;
      auto pcOffset           = data["pcOffset"].parseVector!int;
      auto factionTitleOffset = data["factionTitleOffset"].parseVector!int;
      auto playerTitleOffset  = data["playerTitleOffset"].parseVector!int;
      auto pcTitleOffset      = data["pcTitleOffset"].parseVector!int;
      auto startButtonOffset  = data["startButtonOffset"].parseVector!int;
      auto mapOffset          = data["mapSelectOffset"].parseVector!int;

      auto mapPaths = Paths.mapDir.dirEntries("*.json", SpanMode.shallow);
      auto mapNames = mapPaths.map!(x => x.baseName(".json"));

      addChild(new TextBox(data.child["playerText"], "Player", playerTitleOffset));
      addChild(new TextBox(data.child["playerText"], "PC", pcTitleOffset));
      addChild(new TextBox(data.child["factionText"], "Faction", factionTitleOffset));

      _startButton = new Button(data.child["startButton"], startButtonOffset, &startBattle);
      _playerFactionMenu = new FactionMenu(playerOffset, &selectPlayerFaction);
      _pcFactionMenu     = new FactionMenu(pcOffset, &selectPCFaction);
      _mapSelector = new StringSelection(getGUIData("selectMap"), mapOffset, mapNames.array);

      addChildren(_startButton, _playerFactionMenu, _pcFactionMenu, _mapSelector);
      _startButton.enabled = false;

      addChild(new Button(data.child["backButton"], () => title.states.setState(new ShowTitle)));
  }

  private:
  FactionMenu _playerFactionMenu, _pcFactionMenu;
  StringSelection _mapSelector;
  Button _startButton;

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
}
