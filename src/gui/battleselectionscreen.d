module gui.battleselectionscreen;

import std.string;
import std.conv;
import dau.all;
import model.all;
import gui.factionmenu;

/// bar that displays progress as discrete elements (pips)
class BattleSelectionScreen : GUIElement {
  this() {
    super(getGUIData("selectBattle"), Vector2i.zero);
      auto playerOffset       = data["playerOffset"].parseVector!int;
      auto pcOffset           = data["pcOffset"].parseVector!int;
      auto factionTitleOffset = data["factionTitleOffset"].parseVector!int;
      auto playerTitleOffset  = data["playerTitleOffset"].parseVector!int;
      auto pcTitleOffset      = data["pcTitleOffset"].parseVector!int;
      auto startButtonOffset  = data["startButtonOffset"].parseVector!int;

      addChild(new TextBox(data.child["playerText"], "Player", playerTitleOffset));
      addChild(new TextBox(data.child["playerText"], "PC", pcTitleOffset));
      addChild(new TextBox(data.child["factionText"], "Faction", factionTitleOffset));

      auto _playerFactionMenu = new FactionMenu(playerOffset, &selectPlayerFaction);
      auto _pcFactionMenu     = new FactionMenu(pcOffset, &selectPlayerFaction);

      addChildren(_playerFactionMenu, _pcFactionMenu);

      /*
      "startButton": {
      }
      */
  }

  private:
  FactionMenu _playerFactionMenu, _pcFactionMenu;

  void selectPlayerFaction(Faction faction) {
  }
}
