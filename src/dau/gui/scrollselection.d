module dau.gui.scrollselection;

import std.conv, std.traits;
import dau.geometry.all;
import dau.graphics.all;
import dau.util.all;
import dau.gui.element;
import dau.gui.data;
import dau.gui.button;

/// select one of multiple elements using horizontal scroll buttons
abstract class ScrollSelection(EntryType) : GUIElement {
  alias Action = void delegate(EntryType);
  this(GUIData data, Vector2i pos, EntryType[] entries, Action onChange = doNothing!Action) {
    assert(entries.length > 0, "a ScrollSelection must have at least 1 entry provided");
    super(data, pos, Anchor.center);
    _entries          = bicycle(entries);
    _currentSelection = entries[0];
    _onChange         = onChange;

    int buttonSpacingX = data.get("buttonSpacingX", "0").to!int;
    auto leftPos = Vector2i(-buttonSpacingX, height / 2);
    auto rightPos = Vector2i(area.width + buttonSpacingX, height / 2);

    _prev = addChild(new Button(data.child["prevButton"], leftPos,  &selectPrevious, Anchor.center));
    _next = addChild(new Button(data.child["nextButton"], rightPos, &selectNext,     Anchor.center));

    _currentElement = addChild(createEntry(_currentSelection, size / 2));
  }

  /// the currently selected entry
  @property {
    EntryType selection() { return _currentSelection; }
    void selection(EntryType entry) {
      if (entry == _currentSelection) { return; }
      EntryType next;
      do {
        next = _entries.advance;
      } while (next != entry && next != _currentSelection);
      _currentSelection = next;
      updateEntry();
    }

    void enabled(bool val) {
      sprite.tint = val ? Color.white : color(1,1,1,0.5);
      _enabled = val;
      _next.enabled = val;
      _prev.enabled = val;
    }

    bool enabled() { return _enabled; }
  }

  void selectPrevious() {
    _currentSelection = _entries.reverse;
    updateEntry();
    _onChange(_currentSelection);
  };

  void selectNext() {
    _currentSelection = _entries.advance;
    updateEntry();
    _onChange(_currentSelection);
  };

  GUIElement createEntry(EntryType entry, Vector2i pos);

  private:
  Bicycle!(EntryType[]) _entries;
  EntryType             _currentSelection;
  GUIElement            _currentElement;
  Action                _onChange;
  bool                  _enabled;
  Button                _next;
  Button                _prev;

  void updateEntry() {
    _currentElement.active = false;
    _currentElement = addChild(createEntry(_currentSelection, size / 2));
  }
}
