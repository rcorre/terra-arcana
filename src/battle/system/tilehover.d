module battle.system.tilehover;

import dau.all;
import battle.battle;
import model.all;

class TileHoverSystem : System!Battle {
  this(Battle b) {
    super(b);
  }

  @property auto tileUnderMouse() { return _tileUnderMouse; }
  @property auto unitUnderMouse() { return _unitUnderMouse; }
  @property auto tileUnderMouseChanged() { return _newTileUnderMouse; }

  override {
    void update(float time, InputManager input) {
      _newTileUnderMouse = false;
      auto worldMousePos = cast(Vector2i) (input.mousePos + scene.camera.area.topLeft);
      auto tile = scene.map.tileAt(worldMousePos);
      if (tile !is null && _tileUnderMouse != tile) { // moved cursor to new tile
        _newTileUnderMouse = true;
        _tileUnderMouse = tile;
        _unitUnderMouse = cast(Unit) tile.entity;
      }
    }

    void start() {
    }

    void stop() {
    }
  }

  private:
  Tile _tileUnderMouse;
  Unit _unitUnderMouse;
  bool _newTileUnderMouse;
}
