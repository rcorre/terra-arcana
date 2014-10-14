module state.battle;

import dau.all;
import model.tilemap;

class Battle : GameState {
  override {
    void start() { 
      registerEntity(new TileMap("test"));
    }

    void update(float time) { 
    }

    void draw() { 
    }

    void end() { 
    }
  }
}
