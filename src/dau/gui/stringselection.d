module dau.gui.stringselection;

import dau.geometry.all;
import dau.graphics.all;
import dau.util.all;
import dau.gui.data;
import dau.gui.element;
import dau.gui.scrollselection;
import dau.gui.textbox;

/// select one of multiple string values using horizontal scroll buttons
class StringSelection : ScrollSelection!string {
  this(GUIData data, Vector2i pos, string[] entries, Action onChange = doNothing!Action) {
    super(data, pos, entries, onChange);
  }

  override GUIElement createEntry(string text, Vector2i pos) {
    return new TextBox(data.child["text"], text, pos, Anchor.center);
  }
}
