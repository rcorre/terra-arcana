module gui.mapselector;

import std.conv, std.algorithm, std.range;
import dau.all;
import model.all;

/// select one of multiple maps
class MapSelector : GUIElement {
  alias Action = void delegate(MapLayout);

  this(GUIData data, MapLayout[] layouts, Action onChange = doNothing!Action) {
    super(data);
    string[] maps;
    foreach(layout ; layouts) {
      if (!maps.canFind(layout.mapName)) { maps ~= layout.mapName; }
    }
    _layouts     = layouts;
    _onChange    = onChange;
    _mapSelector = addChild(new StringSelection(data.child["chooseMap"], maps, &setMap));
    _description = addChild(new TextBox(data.child["description"]));

    createLayoutSelector(maps[0]);
    _description.text = selection.description;
  }

  @property {
    auto selection() {
      return _layouts.find!(x => x.mapName == _mapSelector.selection &&
          x.layoutName == _layoutSelector.selection).front;
    }
  }

  void setSelection(string mapName, string layoutName) {
    _mapSelector.selection = mapName;
    _layoutSelector.selection = layoutName;
  }

  private:
  PipBar          _difficulty;
  StringSelection _layoutSelector;
  StringSelection _mapSelector;
  TextBox         _description;
  MapLayout[]     _layouts;
  Action          _onChange;

  void setMap(string mapName) {
    if (_layoutSelector !is null) { _layoutSelector.active = false; }
    createLayoutSelector(mapName);
    setLayout(_layoutSelector.selection);
  }

  void setLayout(string name) {
    _onChange(selection);
    _description.text = selection.description;
  }

  void createLayoutSelector(string mapName) {
    auto layouts = _layouts.filter!(x => x.mapName == mapName).map!(x => x.layoutName).array;
    _layoutSelector = addChild(new StringSelection(data.child["chooseLayout"], layouts, &setLayout));
  }
}
