module dau.gui.menu;

import std.algorithm;
import dau.geometry.all;
import dau.graphics.all;
import dau.gui.all;
import dau.util.removal_list;

abstract class Menu(EntryType, ButtonType) : GUIElement {
  this(Sprite bgSprite, Vector2i pos, Vector2i firstButtonOffset) {
    super(sprite, pos, Anchor.topLeft);
    _nextButtonOffset = firstButtonOffset;
  }

  protected void addEntry(EntryType entry) {
    auto button = new ButtonType(entry, _nextButtonOffset);
    addChild(button);
    _nextButtonOffset.y += button.height;
  }

  private Vector2i _nextButtonOffset;
}

abstract class MenuButton(EntryType) : GUIElement {
  this(EntryType entry, Sprite sprite, Vector2i pos) {
    super(sprite, pos, Anchor.topLeft);
  }
}
