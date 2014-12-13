module battle.system.tilehover;

import dau.all;
import battle.battle;
import model.all;
import gui.unitinfo;
import gui.unitpreview;

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

      // handle displaying unit info
      if (_unitUnderMouse is null || !input.inspect) {
        destroyUnitInfo();
      }
      if (input.inspect && _unitUnderMouse !is null) {
        if (_unitInfo is null || _unitUnderMouse != _unitInfo.unit) {
          destroyUnitInfo();
          _unitInfo = new UnitInfoGUI(_unitUnderMouse, _unitUnderMouse.center);
          scene.gui.addElement(_unitInfo);
        }
        positionUnitInfo(input.mousePos);
      }

      // display unit preview
      if (_newTileUnderMouse) {
        destroyUnitPreview();
        if (_unitUnderMouse !is null) {
          _unitPreview = scene.gui.addElement(new UnitPreview(_unitUnderMouse));
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
  bool _newTileUnderMouse;
  UnitInfoGUI _unitInfo;
  UnitPreview _unitPreview;

  void destroyUnitInfo() {
    if (_unitInfo !is null) {
      _unitInfo.active = false;
      _unitInfo = null;
    }
  }

  void destroyUnitPreview() {
    if (_unitPreview !is null) {
      _unitPreview.active = false;
      _unitPreview = null;
    }
  }

  void positionUnitInfo(Vector2i mousePos) {
    auto center = Vector2i(Settings.screenW, Settings.screenH) / 2;
    if (mousePos.x < center.x) {
      if (mousePos.y < center.y) {
        _unitInfo.area.topLeft = mousePos;
      }
      else {
        _unitInfo.area.topLeft = mousePos - Vector2i(0, _unitInfo.totalSize.y);
      }
    }
    else {
      if (mousePos.y < center.y) {
        _unitInfo.area.topRight = mousePos;
      }
      else {
        _unitInfo.area.topRight = mousePos - Vector2i(0, _unitInfo.totalSize.y);
      }
    }
  }
}
