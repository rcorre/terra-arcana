module dau.graphics.camera;

import dau.engine;
import dau.geometry.all;

class Camera {
  this(int width, int height) {
    _area = Rect2i(bounds.topLeft, width, height);
    _bounds = Rect2i(0, 0, width, height);
  }

  this(int width, int height, Rect2i bounds) {
    _area = Rect2i(bounds.topLeft, width, height);
    _bounds = bounds;
  }

  @property {
    auto area() { return _area; }
    auto transform() {
      al_identity_transform(&_transform);
      al_translate_transform(&_transform, -_area.left, -_area.top);
      return &_transform;
    }

    auto bounds() { return _bounds; }
    void bounds(Rect2i bounds) {
      _bounds = bounds;
      _area.keepInside(bounds);
    }
  }

  void move(Vector2i disp) {
    _area.center = _area.center + disp;
    _area.keepInside(_bounds);
  }

  void place(Vector2i center) {
    _area.center = center;
    _area.keepInside(_bounds);
  }

  private:
  Rect2i _area, _bounds;
  ALLEGRO_TRANSFORM _transform;
}

Camera mainCamera;

static this() {
  onInit({ mainCamera = new Camera(Settings.screenW, Settings.screenH); });
}
