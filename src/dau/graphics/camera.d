module dau.graphics.camera;

import dau.setup;
import dau.allegro;
import dau.geometry.all;

class Camera {
  this(int width, int height) {
    _area = Rect2f(0, 0, width, height);
    _bounds = _area;
  }

  @property {
    auto transform() {
      al_identity_transform(&_transform);
      al_translate_transform(&_transform, -_area.left, -_area.top);
      return &_transform;
    }

    auto area() { return _area; }
    void area(T)(Rect2!T area) {
      _area = cast(Rect2f) area;
      _area.keepInside(bounds);
    }

    auto bounds() { return _bounds; }
    void bounds(T)(Rect2!T bounds) {
      _bounds = cast(Rect2f) bounds;
      _area.keepInside(bounds);
    }

    int clipWidth()  { return cast(int) _area.width; }
    int clipHeight() { return cast(int) _area.height; }
  }

  /// move camera by disp, but not outside its bounds
  /// return the distance moved
  auto move(T)(Vector2!T disp) {
    auto prevPos = area.center;
    _area.center = _area.center + cast(Vector2f) disp;
    _area.keepInside(_bounds);
    return _area.center - prevPos;
  }

  void place(T)(Vector!T center) {
    _area.center = cast(Vector2f) center;
    _area.keepInside(_bounds);
  }

  private:
  Rect2f _area, _bounds;
  ALLEGRO_TRANSFORM _transform;
}
