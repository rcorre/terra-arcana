module dau.gui.element;

import dau.gui.data;
import dau.geometry.all;
import dau.graphics.all;
import dau.util.removal_list;

class GUIElement {
  alias HoverHandler = void delegate(bool);

  enum Anchor {
    center,
    topLeft
  }

  const string toolTipText;
  const string toolTipTitle;

  this(GUIData data, Vector2i pos, Anchor anchor = Anchor.topLeft) {
    auto textureName = data.get("texture", null);
    auto spriteName = data.get("sprite", null);
    _sprite = (textureName is null) ? null : new Sprite(textureName, spriteName);
    Rect2i area;
    final switch (anchor) with (Anchor) {
      case topLeft:
        area = Rect2i(pos, _sprite.width, _sprite.height);
        break;
      case center:
        area = Rect2i.centeredAt(pos, _sprite.width, _sprite.height);
        break;
    }
    this(data, area);
  }

  this(GUIData data, Rect2i area) {
    _area = area;
    _children = new ChildList;
    _hoverHandler = delegate(bool) { };
    onMouseLeave(); // assume mouse not in area to begin with
    toolTipText = data.get("toolTipText", null);
    toolTipTitle = data.get("toolTipTitle", null);
    _data = data;
  }

  @property {
    auto area() { return _area; }
    auto width() { return _area.width; }
    auto height() { return _area.height; }
    auto size() { return Vector2i(width, height); }

    auto sprite() { return _sprite; }

    bool active() { return _active; }
    void active(bool val) { _active = val; }

    auto children() { return _children[]; }

    auto data() { return _data; }
  }

  void onMouseEnter() {}
  void onMouseLeave() {}
  bool onClick() { return false; } // return false to indicate event not handled

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

  void flash(float time, Color color) {
    if (sprite !is null) {
      sprite.flash(time, color);
    }
    foreach(child ; children) {
      child.flash(time, color);
    }
  }

  final {
    auto addChild(GUIElement el) {
      _children.insert(el);
      return el;
    }

    void addChildren(GUIElement[] elements ...) {
      foreach(el ; elements) {
        _children.insert(el);
      }
    }

    /// return most-nested element under mouse
    GUIElement handleMouseHover(Vector2i pos, Vector2i prevPos) {
      bool mouseInArea = area.contains(pos);
      bool mouseWasInArea = area.contains(prevPos);
      GUIElement hoveredElement = mouseInArea ? this : null;
      if (mouseInArea && !mouseWasInArea) {
        onMouseEnter();
        _hoverHandler(true);
      }
      else if (!mouseInArea && mouseWasInArea) {
        onMouseLeave();
        _hoverHandler(false);
      }

      auto localPos = pos - area.topLeft;
      auto prevLocalPos = prevPos - area.topLeft;
      foreach(child ; children) {
        auto underMouse = child.handleMouseHover(localPos, prevLocalPos);
        hoveredElement = (underMouse is null) ? hoveredElement : underMouse;
      }
      return hoveredElement;
    }

    bool handleMouseClick(Vector2i pos) {
      if (!area.contains(pos)) { return false; }
      auto localPos = pos - area.topLeft;
      foreach(child ; children) {
        if (child.handleMouseClick(localPos)) {
          return true;
        }
      }
      return onClick();
    }

    void onHover(HoverHandler handler) {
      _hoverHandler = handler;
    }
  }

  private:
  alias ChildList = RemovalList!(GUIElement, x => !x.active);
  Sprite _sprite;
  Rect2i _area;
  ChildList _children;
  bool _active = true;
  HoverHandler _hoverHandler;
  GUIData _data;
}
