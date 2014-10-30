module dau.gui.menu;

import std.algorithm;
import dau.geometry.all;
import dau.graphics.all;
import dau.gui.all;
import dau.util.removal_list;

abstract class Menu(EntryType, ButtonType) : GUIElement {
  this(Sprite bgSprite, Vector2i pos, Vector2i firstButtonOffset, ButtonType.Action onClick) {
    super(bgSprite, pos, Anchor.topLeft);
    _nextButtonOffset = firstButtonOffset;
    _onClick = onClick;
  }

  protected void addEntry(EntryType entry) {
    auto button = new ButtonType(entry, _nextButtonOffset, _onClick);
    addChild(button);
    _nextButtonOffset.y += button.height;
  }

  private:
  Vector2i _nextButtonOffset;
  ButtonType.Action _onClick;
}

abstract class MenuButton(EntryType) : GUIElement {
  alias Action = void delegate(EntryType);
  this(EntryType entry, Sprite sprite, Vector2i pos, Action onClick) {
    super(sprite, pos, Anchor.topLeft);
    _onClick = onClick;
    _value = entry;
  }

  override bool onClick() {
    _onClick(_value);
    return true;
  }

  private:
  Action _onClick;
  EntryType _value;
}
