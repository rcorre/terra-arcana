module dau.gui.element;

import std.algorithm;
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
    if (textureName !is null) {
      auto animName = data.get("animation", null);
      if (animName !is null) {
        _sprite = new Animation(textureName, animName, Animation.Repeat.loop);
      }
      else {
        auto spriteName = data.get("sprite", null);
        _sprite = new Sprite(textureName, spriteName);
      }
    }
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
    auto animation() { return cast(Animation) _sprite; }

    bool active() { return _active; }
    void active(bool val) { _active = val; }

    bool hasFocus() { return _hasFocus; }

    auto children() { return _children[]; }

    auto data() { return _data; }
    /// if true, mouse should be highlighted when hovering over this element
    bool highlightCursorOnHover() { return false; }
  }

  auto childrenOfType(T)() {
    return children.map!(x => cast(T) x).filter!(x => x !is null);
  }

  void onMouseEnter() {}
  void onMouseLeave() {}
  bool onClick() { return false; } // return false to indicate event not handled
  void onFocus(bool focused) { }

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

  void clear() {
    foreach(child ; children) {
      child.active = false;
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

    /// automatically add children from the given keys
    void addChildren(T)(string[] keys ...) if(is(typeof(new T(GUIData.init)) : GUIElement)) {
      foreach(key ; keys) {
        addChild(new T(data.child[key]));
      }
    }

    /// return most-nested element under mouse.
    GUIElement handleMouseHover(Vector2i pos, Vector2i prevPos, ref bool highlightCursor) {
      bool mouseInArea = area.contains(pos);
      bool mouseWasInArea = area.contains(prevPos);
      GUIElement hoveredElement = mouseInArea ? this : null;
      highlightCursor = highlightCursor || (mouseInArea && highlightCursorOnHover);
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
        auto underMouse = child.handleMouseHover(localPos, prevLocalPos, highlightCursor);
        hoveredElement = (underMouse is null) ? hoveredElement : underMouse;
      }
      return hoveredElement;
    }

    bool handleMouseClick(Vector2i pos) {
      _hasFocus = area.contains(pos);
      onFocus(_hasFocus);
      auto localPos = pos - area.topLeft;
      foreach(child ; children) {
        if (child.handleMouseClick(localPos)) {
          return true;
        }
      }
      return _hasFocus ? onClick() : false;
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
  bool _hasFocus;
}
