module battle.playerturn;

import dau.all;
import model.all;
import battle.battle;

class PlayerTurn : State!Battle {
  override {
    void enter(Battle b) {
      b.enableCameraControl = true;
    }
  }

  override void update(Battle b, float time, InputManager input) {
    auto tile = b.map.tileAt(input.mousePos);
    if (tile !is null && b.tileUnderMouse != tile) { // moved cursor to new tile
      b.tileUnderMouse = tile;
      auto unit = cast(Unit) tile.entity;
      if (unit is null) {
        b.clearUnitInfo();
      }
      else {
        b.setUnitInfo(unit);
      }
    }
  }
}
