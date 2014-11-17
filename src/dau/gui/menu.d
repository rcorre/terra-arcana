module dau.gui.menu;

import std.algorithm, std.conv, std.traits;
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
    _onClick = delegate(EntryType entry) {
      onClick(entry);
      setSelection(entry);
    };
  }


  /// the currently selected entry, or the default value of EntryType if none selected
  @property EntryType selection() {
    auto selected = buttons.find!(x => x.isSelected);
    if (selected.empty) { // return default value if no button selected
      return is(typeof(null) : EntryType) ? null : EntryType.init;
    }
    return selected.front.entry;
  }

  void setSelection(EntryType entry) {
    foreach(button ; buttons) {
        button.isSelected = button.entry == entry;
    }
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

  @property auto buttons() {
    return children.map!(x => cast(ButtonType) x).filter!(x => x !is null);
  }
}

abstract class MenuButton(EntryType) : GUIElement {
  alias Action = void delegate(EntryType);
  this(GUIData data, EntryType entry, Vector2i pos, Action onClick, bool enabled) {
    super(data, pos, Anchor.topLeft);
    _dullShade = data["dullShade"].parseColor;
    _brightShade = data["brightShade"].parseColor;
    _disabledShade = data["disabledShade"].parseColor;
    _onClick = onClick;
    _entry = entry;
    _enabled = enabled;
    sprite.tint = enabled ? _dullShade : _disabledShade;
  }

  @property {
    EntryType entry() { return _entry; }

    bool isSelected() { return _selected; }

    void isSelected(bool val) {
      if (_enabled) {
        sprite.tint = val ? _brightShade : _dullShade;
      }
      _selected = val;
    }
  }

  override bool onClick() {
    if (_enabled) {
      _onClick(_entry);
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
    if (_enabled && !_selected) {
      sprite.tint = _dullShade;
    }
  }

  private:
  Color _dullShade, _brightShade, _disabledShade;

  protected:
  bool _enabled, _selected;

  private:
  Action _onClick;
  EntryType _entry;
}
