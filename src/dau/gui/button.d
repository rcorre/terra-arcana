module dau.gui.button;

import std.conv;
import dau.gui.element;
import dau.gui.textbox;
import dau.gui.data;
import dau.geometry.all;
import dau.graphics.all;

/// draws a single sprite with a value next to it
class Button : GUIElement {
  alias Action = void delegate();
  this(GUIData data, Action onClick) {
    auto pos = data["offset"].parseVector!int;
    auto anchor = data["anchor"].to!Anchor;
    this(data, pos, onClick, anchor); 
  }

  this(GUIData data, Vector2i pos, Action onClick, Anchor anchor = Anchor.topLeft) {
    _onShade  = data.get("onShade", "1, 1, 1").parseColor;
    _offShade = data.get("offShade", "0.6, 0.6, 0.6").parseColor;
    _disabledShade = data.get("disabledShade", "0.2, 0.2, 0.2").parseColor;
    _onClick = onClick;
    super(data, pos, anchor);
    auto text = data.get("text", null);
    if (text !is null) {
      addChild(new TextBox(data.child["text"], text, size / 2, Anchor.center));
    }
  }

  @property {
    void enabled(bool val) {
      sprite.tint = val ? _offShade : _disabledShade;
      _enabled = val;
    }

    bool enabled() { return _enabled; }
  }

  override {
    void onMouseEnter() {
      if (_enabled) { sprite.tint = _onShade; }
    }

    void onMouseLeave() {
      if (_enabled) { sprite.tint = _offShade; }
    }

    bool onClick() {
      _onClick();
      return true;
    }
  }

  private:
  Color _onShade, _offShade, _disabledShade;
  bool _enabled = true;
  Action _onClick;
}
