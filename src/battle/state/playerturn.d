module battle.state.playerturn;

import dau.all;
import model.all;
import battle.battle;
import battle.system.all;

class PlayerTurn : State!Battle {
  override {
    void enter(Battle b) {
      b.enableCameraControl = true;
      b.enableSystem!TileHoverSystem;
    }
  }

  override void update(Battle b, float time, InputManager input) {
  }
}
