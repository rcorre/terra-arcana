module dau.gui.menu;

import std.algorithm, std.conv;
import dau.geometry.all;
import dau.graphics.all;
import dau.gui.element;
import dau.gui.data;
import dau.util.removal_list;

abstract class Menu(EntryType, ButtonType) : GUIElement {
  this(GUIData data, Vector2i pos, ButtonType.Action onClick) {
    super(data, pos, Anchor.topLeft);
    _nextButtonOffset = data.get("firstButtonOffset", "0,0").parseVector!int;
    _menuSpacingY = data.get("menuSpacingY", "0").to!int;
    _onClick = onClick;
  }

  protected void addEntry(GUIData data, EntryType entry, bool enabled = true) {
    auto button = new ButtonType(data, entry, _nextButtonOffset, _onClick, enabled);
    addChild(button);
    _nextButtonOffset.y += button.height + _menuSpacingY;
  }

  private:
  Vector2i _nextButtonOffset;
  int _menuSpacingY;
  ButtonType.Action _onClick;
}

abstract class MenuButton(EntryType) : GUIElement {
  alias Action = void delegate(EntryType);
  this(GUIData data, EntryType entry, Vector2i pos, Action onClick, bool enabled) {
    super(data, pos, Anchor.topLeft);
    _dullShade = data["dullShade"].parseColor;
    _brightShade = data["brightShade"].parseColor;
    _disabledShade = data["disabledShade"].parseColor;
    _onClick = onClick;
    _value = entry;
    _enabled = enabled;
    sprite.tint = enabled ? _dullShade : _disabledShade;
  }

  override bool onClick() {
    if (_enabled) {
      _onClick(_value);
      return true;
    }
    return false;
  }

  override void onMouseEnter() {
    if (_enabled) {
      sprite.tint = _brightShade;
    }
  }

  override void onMouseLeave() {
    if (_enabled) {
      sprite.tint = _dullShade;
    }
  }

  private:
  Color _dullShade, _brightShade, _disabledShade;

  protected:
  bool _enabled;

  private:
  Action _onClick;
  EntryType _value;
}
