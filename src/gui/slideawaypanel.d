module gui.slideawaypanel;

import std.conv;
import dau.gui.element;
import dau.gui.data;
import dau.geometry.all;
import dau.util.math;

class SlideAwayPanel : GUIElement {
  this(GUIData data, GUIElement[] children ...) {
    auto pos = data.get("offset", "0,0").parseVector!int;
    auto anchor = data.get("anchor", "topLeft").to!Anchor;
    super(data, pos, anchor);
    _endOffset = data["slideOffset"].parseVector!int;
    auto speed = data["slideSpeed"].to!float;
    _endTime = _endOffset.len / speed;
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
