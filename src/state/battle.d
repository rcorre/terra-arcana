module state.battle;

import dau.all;

class Battle : GameState {
  override {
    void start() { 
      registerEntity(new Entity(Vector2i(20, 20), 
            new Animation("sniper", "action1", Animation.Repeat.loop), "unit")); 
    }

    void update(float time) { 
    }

    void draw() { 
    }

    void end() { 
    }
  }
}
