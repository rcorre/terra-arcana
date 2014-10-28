module battle.battle;

import dau.all;
import model.all;
import gui.unitinfo;
import battle.state.playerturn;
import battle.system.all;

private enum {
  cameraScrollSpeed = 12,
}

class Battle : Scene!Battle {
  this() {
    System!Battle[] systems = [
      new TileHoverSystem(this),
      new BattleCameraSystem(this),
    ];
    super(new PlayerTurn, systems);
  }

  override {
    void enter() {
      map = new TileMap("test", entities);
      entities.registerEntity(map);
      camera.bounds = Rect2f(Vector2f.zero, cast(Vector2f) map.totalSize);
      auto unit = new Unit("assault", map.tileAt(3, 3), Team.player);
      entities.registerEntity(unit);
      units ~= unit;
      unit = new Unit("treant", map.tileAt(5, 3), Team.pc);
      entities.registerEntity(unit);
      units ~= unit;
      unit = new Unit("guardian", map.tileAt(3, 5), Team.player);
      entities.registerEntity(unit);
      units ~= unit;
    }

    void update(float time) {
      super.update(time);
    }
  }

  package:
  TileMap map;
  Unit[]  units;
}
