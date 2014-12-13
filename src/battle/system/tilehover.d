module battle.system.tilehover;

import dau.all;
import battle.battle;
import model.all;
import gui.unitinfo;
import gui.unitpreview;
import gui.terrainpreview;

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
        if (_unitUnderMouse !is null) {
          auto unitPreview = cast(UnitPreview) _currentPreview;
          if (unitPreview is null) {
            destroyCurrentPreview();
            _currentPreview = scene.gui.addElement(new UnitPreview(_unitUnderMouse));
          }
          else {
            unitPreview.refresh(_unitUnderMouse);
          }
        }
        else if (_tileUnderMouse !is null) {
          auto terrainPreview = cast(TerrainPreview) _currentPreview;
          if (terrainPreview is null) {
            destroyCurrentPreview();
            _currentPreview = scene.gui.addElement(new TerrainPreview(_tileUnderMouse));
          }
          else {
            terrainPreview.refresh(_tileUnderMouse);
          }
        }
        else {
          destroyCurrentPreview();
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
  DynamicGUIElement _currentPreview;

  void destroyUnitInfo() {
    if (_unitInfo !is null) {
      _unitInfo.active = false;
      _unitInfo = null;
    }
  }

  void destroyCurrentPreview() {
    if (_currentPreview !is null) {
      _currentPreview.transitionActive = false;
      _currentPreview = null;
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
