module dau.gui.element;

import dau.geometry.all;
import dau.graphics.all;
import dau.util.removal_list;

class GUIElement {
  enum Anchor {
    center,
    topLeft
  }

  this(int width, int height) {
    _area = Rect2i(0, 0, width, height);
    _children = new ChildList;
  }

  this(string textureName, Anchor anchor = Anchor.topLeft) {
    _sprite = new Sprite(getTexture(textureName));
    _children = new ChildList;
  }

  this(string textureName, string spriteName, Vector2i pos, Anchor anchor = Anchor.topLeft) {
    _sprite = new Sprite(textureName, spriteName);
    final switch (anchor) with (Anchor) {
      case center:
        _area = Rect2i(pos, _sprite.width, _sprite.height);
        break;
      case topLeft:
        _area = Rect2i.centeredAt(pos, _sprite.width, _sprite.height);
        break;
    }
  }

  @property {
    auto area() { return _area; }
    bool active() { return _active; }
  }

  void update(float time) {
    if (_sprite !is null) {
      _sprite.update(time);
    }
    foreach(child ; _children) {
      child.update(time);
    }
  }

  void draw(Vector2i parentTopLeft) {
    if (_sprite !is null) {
      _sprite.draw(_area.center + parentTopLeft);
    }
    foreach(child ; _children) {
      child.draw(_area.topLeft + parentTopLeft);
    }
  }

  final {
    void addChild(GUIElement el) {
      _children.insert(el);
    }

    void destroy() {
      _active = false;
      foreach(child ; _children) {
        child.destroy();
      }
    }
  }

  private:
  alias ChildList = RemovalList!(GUIElement, x => !x.active);
  Sprite _sprite;
  Rect2i _area;
  ChildList _children;
  bool _active;
}
