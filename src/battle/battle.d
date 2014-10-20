module battle.battle;

import dau.all;
import model.all;
import gui.unitinfo;
import battle.playerturn;

private enum {
  cameraScrollSpeed = 12,
}

class Battle : Scene!Battle {
  this() {
    super(new PlayerTurn);
  }

  override {
    void enter() {
      map = new TileMap("test", entities);
      entities.registerEntity(map);
      mainCamera.bounds = Rect2f(Vector2f.zero, cast(Vector2f) map.totalSize);
      auto unit = new Unit("sniper", map.tileAt(3, 3));
      entities.registerEntity(unit);
      states.pushState(new PlayerTurn);
    }
  }

package:
  TileMap     map;
  Unit[]      units;
  Tile        tileUnderMouse;
  UnitInfoGUI unitInfo;

  void clearUnitInfo() {
    if (unitInfo !is null) {
      unitInfo.active = false;
    }
    unitInfo = null;
  }

  void setUnitInfo(Unit unit) {
    clearUnitInfo();
    unitInfo = new UnitInfoGUI(unit);
    addGUIElement(unitInfo);
  }
}
