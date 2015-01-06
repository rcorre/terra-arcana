module gui.mapselector;

import std.conv;
import dau.all;

/// select one of multiple maps
class MapSelector : ScrollSelection!MapData {
  this(GUIData data, MapData[] entries, Action onChange = doNothing!Action) {
    auto pos = data["offset"].parseVector!int;
    auto del = delegate(MapData map) {
      onChange(map);
      _difficulty.setVal(map.properties.get("difficulty", "1").to!int);
    };
    super(data, pos, entries, del);
    addChild(new Icon(data.child["mapSelectorBottom"]));
    _difficulty = addChild(new PipBar(data.child["difficulty"]));
    _difficulty.setVal(selection.properties.get("difficulty", "1").to!int);
  }

  override GUIElement createEntry(MapData map, Vector2i pos) {
    auto text = map.properties.get("name", "Untitled");
    return new TextBox(data.child["text"], text, pos, Anchor.center);
  }

  private:
  PipBar _difficulty;
}
