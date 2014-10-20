module battle.state.playerturn;

import dau.all;
import model.all;
import battle.battle;
import battle.system.all;
import battle.state.playerunitselected;

class PlayerTurn : State!Battle {
  override {
    void enter(Battle b) {
      b.enableCameraControl = true;
      b.enableSystem!TileHoverSystem;
      b.enableSystem!BattleCameraSystem;
      _tileHoverSys = b.getSystem!TileHoverSystem;
    }
  }

  override void update(Battle b, float time, InputManager input) {
    auto unit = _tileHoverSys.unitUnderMouse;
    if (unit !is null && input.select) {
      b.states.pushState(new PlayerUnitSelected(unit));
    }
  }

  private TileHoverSystem _tileHoverSys;
}
