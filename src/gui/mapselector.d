module gui.mapselector;

import dau.all;

/// select one of multiple maps
class MapSelector : ScrollSelection!MapData {
  this(GUIData data, MapData[] entries, Action onChange = doNothing!Action) {
    auto pos = data["offset"].parseVector!int;
    super(data, pos, entries, onChange);
  }

  override GUIElement createEntry(MapData map, Vector2i pos) {
    auto text = map.properties.get("name", "Untitled");
    return new TextBox(data.child["text"], text, pos, Anchor.center);
  }
}
