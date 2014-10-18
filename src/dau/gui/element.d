module dau.gui.element;

import dau.geometry.all;
import dau.graphics.all;
import dau.util.removal_list;

class GUIElement {
  enum Anchor {
    center,
    topLeft
  }

  this(Sprite sprite, Vector2i pos, Anchor anchor = Anchor.topLeft) {
    _sprite = sprite;
    Rect2i area;
    final switch (anchor) with (Anchor) {
      case topLeft:
        area = Rect2i(pos, _sprite.width, _sprite.height);
        break;
      case center:
        area = Rect2i.centeredAt(pos, _sprite.width, _sprite.height);
        break;
    }
    this(area);
  }

  this(Rect2i area) {
    _area = area;
    _children = new ChildList;
  }

  @property {
    auto area() { return _area; }
    auto sprite() { return _sprite; }

    bool active() { return _active; }
    void active(bool val) { _active = val; }

    auto children() { return _children[]; }
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
  }

  private:
  alias ChildList = RemovalList!(GUIElement, x => !x.active);
  Sprite _sprite;
  Rect2i _area;
  ChildList _children;
  bool _active = true;
}
