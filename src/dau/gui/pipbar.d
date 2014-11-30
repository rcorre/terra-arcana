module dau.gui.pipbar;

import std.conv, std.algorithm : min, max;
import dau.geometry.all;
import dau.graphics.all;
import dau.gui.element;
import dau.gui.data;

/// bar that displays progress as discrete elements (pips)
class PipBar : GUIElement {
  this(GUIData data) {
    auto numPips = data["numPips"].to!int;
    this(data, numPips);
  }

  this(GUIData data, int numPips) {
    auto area = data["area"].parseRect!int;
    this(data, area, numPips);
  }

  this(GUIData data, Rect2i area, int numPips) {
    super(data, area);
    _maxVal = numPips;
    // insert pips, moving horizontally from left to right
    auto pipData = data.child["pip"];
    int pipSpacingX = data.get("pipSpacingX", "0").to!int;
    auto pip = new Pip(pipData, Vector2i.zero);
    auto pos = pip.size / 2; // relative to top left
    for(int i = 0; i < numPips; ++i) {
      pip = new Pip(pipData, pos);
      _pips ~= addChild(pip);
      pos.x += pip.width + pipSpacingX;
    }
    _brightShade   = data.get("brightShade", "1,1,1").parseColor;
    _dimShade      = data.get("dimShade", "1,1,1,0.3").parseColor;
    _negativeShade = data.get("negativeShade", "1,0,0").parseColor;
  }

  void setVal(int val) {
    int idx = 0;
    foreach(pip ; _pips) {
      if (val < 0) {
        pip.sprite.tint = (idx++ < -val) ? _negativeShade : _dimShade;
      }
      else {
        pip.sprite.tint = (idx++ < val) ? _brightShade : _dimShade;
      }
    }
  }

  void transitionVal(int from, int to, float time) {
    int bottom = min(from, to);
    int top = max(from, to);
    int idx = 0;
    foreach(pip ; _pips) {
      if (idx < bottom) {
        pip.sprite.tint =  _brightShade;
      }
      else if (idx >= top) {
        pip.sprite.tint =  _dimShade;
      }
      else {
        pip.sprite.tint = (from > to) ? _brightShade : _dimShade;
        pip.sprite.fade(time, (from > to) ? _dimShade : _brightShade);
      }
      ++idx;
    }
  }

  private:
  int _maxVal;
  GUIElement[] _pips;
  Color _brightShade, _dimShade, _negativeShade;
}

private class Pip : GUIElement {
  this(GUIData data, Vector2i pos) {
    super(data, pos, Anchor.center);
  }
}
