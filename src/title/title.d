module title.title;

import dau.all;
import model.all;
import title.state.selectbattle;

private enum bgColor = color(0, 0.5, 0.5, 0.8);

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
  }

  override {
    void enter() {
      states.setState(new SelectBattle);
    }
  }
}
