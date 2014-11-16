module title.title;

import dau.all;
import model.all;
import gui.factionmenu;
import title.state.selectbattle;

class Title : Scene!Title {
  //this(Player[] players) { // TODO: load players from previous state
  this() {
    System!Title[] systems = [];
    Sprite[string] cursorSprites = [
      "inactive" : new Animation("gui/cursor", "inactive", Animation.Repeat.loop),
      "active"   : new Animation("gui/cursor", "active", Animation.Repeat.loop),
      "ally"     : new Animation("gui/cursor", "ally", Animation.Repeat.loop),
      "enemy"    : new Animation("gui/cursor", "enemy", Animation.Repeat.loop),
      "wait"    : new Animation("gui/cursor", "wait", Animation.Repeat.loop),
    ];
    super(systems, cursorSprites);
    cursor.setSprite("inactive");
    /*
    _playerFactionMenu = new FactionMenu(Vector2i(100, 100), &selectPlayerFaction);
    gui.addElement(_playerFactionMenu);
    */
  }

  override {
    void enter() {
      states.setState(new SelectBattle);
    }
  }

  private:
  FactionMenu _playerFactionMenu, _pcFactionMenu;

  void selectPlayerFaction(Faction faction) {
  }
}
