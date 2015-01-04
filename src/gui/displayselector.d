module gui.displayselector;

import std.string, std.algorithm, std.range;
import dau.all;

/// select one of multiple maps
class DisplaySelector : ScrollSelection!ALLEGRO_DISPLAY_MODE {
  private enum fmt = "%dx%d";
  this(GUIData data, Action onChange = doNothing!Action) {
    auto modes = getSupportedDisplayModes();
    ALLEGRO_DISPLAY_MODE[] entries;
    foreach (mode ; modes) { // remove duplicate resolutions
      if (!entries.canFind!(x => x.width = mode.width && x.height == mode.height)) {
        entries ~= mode;
      }
    }
    auto pos = data["offset"].parseVector!int;
    super(data, pos, entries, onChange);

    auto prefW = Preferences.fetch().screenSizeX;
    auto prefH = Preferences.fetch().screenSizeY;

    auto cur = entries.find!(x => x.width == prefW && x.height == prefH);
    if (!cur.empty) {
      selection = cur.front;
    }
  }

  override GUIElement createEntry(ALLEGRO_DISPLAY_MODE mode, Vector2i pos) {
    auto text = fmt.format(mode.width, mode.height);
    return new TextBox(data.child["text"], text, pos, Anchor.center);
  }
}
