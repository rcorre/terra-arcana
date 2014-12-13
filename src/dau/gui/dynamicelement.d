module dau.gui.dynamicelement;

import std.algorithm, std.conv;
import dau.util.math;
import dau.gui.data;
import dau.gui.element;
import dau.geometry.all;
import dau.graphics.all;

class DynamicGUIElement : GUIElement {
  bool transitionActive;

  this(GUIData data) {
    super(data, area);
    _startPos = area.center;
    _transition = new Transition(data.child["transition"]);
  }

  override void update(float time) {
    super.update(time);

    if (transitionActive && _timer < _transition.duration) { // forwards in time
      _timer = min(_transition.duration, _timer + time);
    }
    else if (_timer > 0) {                                   // backwards in time
      _timer = max(_transition.duration, _timer - time);
    }

    auto newPos = _startPos.lerp(_startPos + _transition.offset, _timer);
    area.center = newPos;
  }

  private:
  Transition _transition; 
  float _timer;
  Vector2i _startPos;
}

private class Transition {
  const float duration;
  const Vector2i offset;

  this(GUIData data) {
    duration = data["duration"].to!float;
    offset = data["offset"].parseVector!int;
  }
}
