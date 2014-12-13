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
    super(data);
    _startPos = area.center;
    _transition = new Transition(data.child["transition"]);
  }

  @property {
    bool transitionComplete() { return _timer >= _transition.duration; }
    bool transitionAtStart() { return _timer <= 0; }
  }

  override void update(float time) {
    super.update(time);

    if (transitionActive && _timer < _transition.duration) { // forward in time
      _timer = min(_transition.duration, _timer + time);
    }
    else if (!transitionActive && _timer > 0) {              // backward in time
      _timer = max(0, _timer - time);
    }

    auto newPos = _startPos.lerp(_startPos + _transition.offset, _timer / _transition.duration);
    area.center = newPos;
  }

  private:
  Transition _transition; 
  float _timer = 0;
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
