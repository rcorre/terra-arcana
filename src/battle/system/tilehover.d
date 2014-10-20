module battle.system.tilehover;

import dau.all;
import battle.battle;
import model.all;
import gui.unitinfo;

class TileHoverSystem : System!Battle {
  this(Battle b) {
    super(b);
  }

  override {
    void update(float time, InputManager input) {
      auto tile = scene.map.tileAt(input.mousePos);
      if (tile !is null && _tileUnderMouse != tile) { // moved cursor to new tile
        _tileUnderMouse = tile;
        auto unit = cast(Unit) tile.entity;
        if (unit is null) {
          clearUnitInfo();
        }
        else {
          setUnitInfo(unit);
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
  UnitInfoGUI _unitInfo;

  void clearUnitInfo() {
    if (_unitInfo !is null) {
      _unitInfo.active = false;
    }
    _unitInfo = null;
  }

  void setUnitInfo(Unit unit) {
    clearUnitInfo();
    _unitInfo = new UnitInfoGUI(unit);
    scene.gui.addElement(_unitInfo);
  }
}
