module dau.gui.pipbar;

import dau.geometry.all;
import dau.graphics.all;
import dau.gui.element;

private enum {
  pipDimShade = Color(0.25, 0.25, 0.25), /// shade to tint 'dimmed' pips with
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
      addChild(new Pip(sprite, pos));
      pos.x += sprite.width;
      sprite = new Sprite(textureName, spriteName);
    }
  }

  void setVal(int val) {
    int idx = 0;
    foreach(child ; children) {
      child.sprite.tint = (idx++ < val) ? Color.white : pipDimShade;
    }
  }

  private:
  int _maxVal;
}

private class Pip : GUIElement {
  this(Sprite sprite, Vector2i pos) {
    super(sprite, pos, Anchor.center);
  }

  @property void dimmed(bool dim) {
    sprite.tint = dim ? pipDimShade : Color.white;
  }
}
