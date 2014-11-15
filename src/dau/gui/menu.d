module dau.gui.menu;

import std.algorithm;
import dau.geometry.all;
import dau.graphics.all;
import dau.gui.element;
import dau.gui.data;
import dau.util.removal_list;

abstract class Menu(EntryType, ButtonType) : GUIElement {
  this(GUIData data, Vector2i pos, Vector2i firstButtonOffset, ButtonType.Action onClick) {
    super(data, pos, Anchor.topLeft);
    _nextButtonOffset = firstButtonOffset;
    _onClick = onClick;
  }

  protected void addEntry(GUIData data, EntryType entry, bool enabled = true) {
    auto button = new ButtonType(data, entry, _nextButtonOffset, _onClick, enabled);
    addChild(button);
    _nextButtonOffset.y += button.height;
  }

  private:
  Vector2i _nextButtonOffset;
  ButtonType.Action _onClick;
}

abstract class MenuButton(EntryType) : GUIElement {
  alias Action = void delegate(EntryType);
  this(GUIData data, EntryType entry, Vector2i pos, Action onClick, bool enabled) {
    super(data, pos, Anchor.topLeft);
    _onClick = onClick;
    _value = entry;
    _enabled = enabled;
  }

  override bool onClick() {
    if (_enabled) {
      _onClick(_value);
      return true;
    }
    return false;
  }

  protected:
  bool _enabled;

  private:
  Action _onClick;
  EntryType _value;
}
