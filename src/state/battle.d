module state.battle;

import dau.all;
import model.tilemap;

private enum {
  cameraScrollSpeed = 12,
}

class Battle : GameState {
  override {
    void start() { 
      _map = new TileMap("test");
      registerEntity(_map);
      mainCamera.bounds = Rect2f(Vector2f.zero, cast(Vector2f) _map.totalSize);
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
}
