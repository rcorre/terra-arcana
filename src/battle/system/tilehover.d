module battle.system.tilehover;

import dau.all;
import battle.battle;
import model.all;
import gui.unitinfo;

class TileHoverSystem : System!Battle {
  this(Battle b) {
    super(b);
  }

  @property auto tileUnderMouse() { return _tileUnderMouse; }
  @property auto unitUnderMouse() { return _unitUnderMouse; }

  override {
    void update(float time, InputManager input) {
      auto tile = scene.map.tileAt(input.mousePos);
      if (tile !is null && _tileUnderMouse != tile) { // moved cursor to new tile
        _tileUnderMouse = tile;
        _unitUnderMouse = cast(Unit) tile.entity;
        if (_unitUnderMouse is null) {
          clearUnitInfo();
        }
        else {
          setUnitInfo();
        }
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
  UnitInfoGUI _unitInfo;

  void clearUnitInfo() {
    if (_unitInfo !is null) {
      _unitInfo.active = false;
    }
    _unitInfo = null;
  }

  void setUnitInfo() {
    clearUnitInfo();
    _unitInfo = new UnitInfoGUI(_unitUnderMouse);
    scene.gui.addElement(_unitInfo);
  }
}
