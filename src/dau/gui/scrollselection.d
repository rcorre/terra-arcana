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
      _currentElement = createEntry(_currentSelection, _currentElement.area.topLeft);
      onChange(_currentSelection);
    };

    auto clickNext = delegate() {
      _currentSelection = _entries.advance;
      _currentElement.active = false;
      _currentElement = createEntry(_currentSelection, _currentElement.area.topLeft);
      onChange(_currentSelection);
    };

    Vector2i childPos = area.topLeft;
    int buttonSpacing = data.get("buttonSpacingX", "0").to!int;

    GUIElement button = addChild(new Button(data.child["prevButton"], childPos, clickPrev));
    childPos.x += button.width + buttonSpacing;

    _currentElement = addChild(createEntry(_currentSelection, childPos));
    childPos.x += _currentElement.width + buttonSpacing;

    addChild(new Button(data.child["nextButton"], childPos, clickNext));
  }

  /// the currently selected entry
  @property EntryType selection() { return _currentSelection; }

  GUIElement createEntry(EntryType entry, Vector2i pos);

  private:
  Bicycle!(EntryType[]) _entries;
  EntryType _currentSelection;
  GUIElement _currentElement;
}
