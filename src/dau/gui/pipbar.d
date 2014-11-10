module dau.gui.pipbar;

import std.algorithm : min, max;
import dau.geometry.all;
import dau.graphics.all;
import dau.gui.element;

private enum {
  dimShade = color(0.25, 0.25, 0.25), /// shade to tint 'dimmed' pips with
  negativeShade = color(1.00, 0, 0), /// shade to tint 'negative' pips with
}

/// bar that displays progress as discrete elements (pips)
class PipBar : GUIElement {
  this(Rect2i area, int numPips, string textureName, string spriteName) {
    super(area);
    _maxVal = numPips;
    // insert pips, moving horizontally from left to right
    auto sprite = new Sprite(textureName, spriteName);
    auto pos = sprite.size / 2; // relative to top left
    for(int i = 0; i < numPips; ++i) {
      _pips ~= addChild(new Pip(sprite, pos));
      pos.x += sprite.width;
      sprite = new Sprite(textureName, spriteName);
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
  this(Sprite sprite, Vector2i pos) {
    super(sprite, pos, Anchor.center);
  }
}
