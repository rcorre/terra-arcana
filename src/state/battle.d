module state.battle;

import dau.all;
import model.all;

private enum {
  cameraScrollSpeed = 12,
}

class Battle : GameState {
  override {
    void start() { 
      _map = new TileMap("test");
      registerEntity(_map);
      mainCamera.bounds = Rect2f(Vector2f.zero, cast(Vector2f) _map.totalSize);
      auto unit = new Unit("sniper", _map.tileAt(3, 3));
      registerEntity(unit);
    }

    void update(float time) { 
      mainCamera.move(Input.scrollDirection * cameraScrollSpeed);
    }

    void draw() { 
    }

    void end() { 
    }
  }

  private:
  TileMap _map;
  Unit[] _units;
}
