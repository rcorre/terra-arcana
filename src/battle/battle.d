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
    ];
    super(new PlayerTurn, systems);
  }

  override {
    void enter() {
      map = new TileMap("test", entities);
      entities.registerEntity(map);
      camera.bounds = Rect2f(Vector2f.zero, cast(Vector2f) map.totalSize);
      auto unit = new Unit("sniper", map.tileAt(3, 3));
      entities.registerEntity(unit);
      states.pushState(new PlayerTurn);
    }

    void update(float time) {
      super.update(time);
      if (enableCameraControl) {
        camera.move(input.scrollDirection * cameraScrollSpeed);
      }
    }
  }

package:
  TileMap     map;
  Unit[]      units;
  bool enableCameraControl;
}
