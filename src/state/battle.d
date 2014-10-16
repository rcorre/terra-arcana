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
      auto tile = _map.tileAt(Input.mousePos);
      if (tile !is null && _tileUnderMouse != tile) { // moved cursor to new tile
        _tileUnderMouse = tile;
        auto unit = cast(Unit) tile.entity;
        if (unit !is null) {
          setUnitInfo(unit);
        }
      }
    }

    void draw() { 
    }

    void end() { 
    }
  }

  private:
  TileMap _map;
  Unit[] _units;
  Tile _tileUnderMouse;
  GUIElement _unitInfo;

  void clearUnitInfo() {
    if (_unitInfo !is null) {
      _unitInfo.active = false;
    }
    _unitInfo = null;
  }

  void setUnitInfo(Unit unit) {
    _unitInfo = new GUIElement(new Sprite("gui/unit_status"), unit.area.bottomRight);
    addGUIElement(_unitInfo);
  }
}
