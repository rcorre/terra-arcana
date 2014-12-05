module gui.slideawaypanel;

import std.conv;
import dau.gui.element;
import dau.gui.data;
import dau.geometry.all;
import dau.util.math;

class SlideAwayPanel : GUIElement {
  this(GUIData data, GUIElement[] children ...) {
    super(data);
    _endOffset = data["slideOffset"].parseVector!int;
    auto speed = data["slideSpeed"].to!float;
    _endTime = _endOffset.len / speed;
    foreach(child ; children) {
      addChild(child);
    }
  }

  override {
    void onMouseEnter() {
      _slideAway = true;
    }

    void onMouseLeave() {
      _slideAway = false;
    }

    void update(float time) {
      _timer += (_slideAway) ? time : -time;
      _timer = _timer.clamp(0, _endTime);
    }
  }

  override void draw(Vector2i parentTopLeft) {
    auto offset = cast(Vector2i) (_endOffset * _timer / _endTime);
    super.draw(parentTopLeft + offset);
  }

  private:
  Vector2i _endOffset;
  float _timer, _endTime;
  bool _slideAway;
}
