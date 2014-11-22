module dau.gui.pipbar;

import std.conv, std.algorithm : min, max;
import dau.geometry.all;
import dau.graphics.all;
import dau.gui.element;
import dau.gui.data;

private enum {
  dimShade = color(0.25, 0.25, 0.25), /// shade to tint 'dimmed' pips with
  negativeShade = color(1.00, 0, 0), /// shade to tint 'negative' pips with
}

/// bar that displays progress as discrete elements (pips)
class PipBar : GUIElement {
  this(GUIData data) {
    auto area = data["pipBarArea"].parseRect!int;
    auto numPips = data["numPips"].to!int;
    this(data, area, numPips);
  }

  this(GUIData data, Rect2i area, int numPips) {
    super(data, area);
    _maxVal = numPips;
    // insert pips, moving horizontally from left to right
    auto pipData = data.child["pip"];
    auto pip = new Pip(pipData, Vector2i.zero);
    auto pos = pip.size / 2; // relative to top left
    for(int i = 0; i < numPips; ++i) {
      pip = new Pip(pipData, pos);
      _pips ~= addChild(pip);
      pos.x += pip.width;
    }
  }

  void setVal(int val) {
    int idx = 0;
    foreach(pip ; _pips) {
      if (val < 0) {
        pip.sprite.tint = (idx++ < -val) ? negativeShade : dimShade;
      }
      else {
        pip.sprite.tint = (idx++ < val) ? Color.white : dimShade;
      }
    }
  }

  void transitionVal(int from, int to, float time) {
    int bottom = min(from, to);
    int top = max(from, to);
    int idx = 0;
    foreach(pip ; _pips) {
      if (idx < bottom) {
        pip.sprite.tint =  Color.white;
      }
      else if (idx >= top) {
        pip.sprite.tint =  dimShade;
      }
      else {
        pip.sprite.tint = (from > to) ? Color.white : dimShade;
        pip.sprite.fade(time, (from > to) ? dimShade : Color.white);
      }
      ++idx;
    }
  }

  private:
  int _maxVal;
  GUIElement[] _pips;
}

private class Pip : GUIElement {
  this(GUIData data, Vector2i pos) {
    super(data, pos, Anchor.center);
  }
}
