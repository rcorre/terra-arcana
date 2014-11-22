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
    _entries = bicycle(entries);
    _currentSelection = entries[0];

    auto clickPrev = delegate() {
      _currentSelection = _entries.reverse;
      _currentElement.active = false;
      _currentElement = addChild(createEntry(_currentSelection, size / 2));
      onChange(_currentSelection);
    };

    auto clickNext = delegate() {
      _currentSelection = _entries.advance;
      _currentElement.active = false;
      _currentElement = addChild(createEntry(_currentSelection, size / 2));
      onChange(_currentSelection);
    };

    int buttonSpacingX = data.get("buttonSpacingX", "0").to!int;
    auto leftPos = Vector2i(-buttonSpacingX, height / 2);
    auto rightPos = Vector2i(area.width + buttonSpacingX, height / 2);

    addChild(new Button(data.child["prevButton"], leftPos, clickPrev, Anchor.center));
    addChild(new Button(data.child["nextButton"], rightPos, clickNext, Anchor.center));

    _currentElement = addChild(createEntry(_currentSelection, size / 2));
  }

  /// the currently selected entry
  @property EntryType selection() { return _currentSelection; }

  GUIElement createEntry(EntryType entry, Vector2i pos);

  private:
  Bicycle!(EntryType[]) _entries;
  EntryType _currentSelection;
  GUIElement _currentElement;
}
