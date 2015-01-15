module model.maplayout;

import std.algorithm, std.string, std.math, std.file, std.path, std.conv, std.array;
import dau.all;
import model.tile;

enum MapType {
  battle,
  skirmish,
  tutorial
}

/// represents a particular setup for a map
/// each map defines a single terrain, but map define multiple object layers
/// a map layout represents a single terrain+object layer combination
class MapLayout {
  private enum {
    factionFormat = "faction%d",
    baseCPformat  = "player%dcp"
  }
  private {
    MapData  _data;
    MapLayer _layer;
  }

  this(MapData data, MapLayer layer) {
    _data = data;
    _layer = layer;
  }

  @property            {
    auto type()        { return _layer.properties.get("type", "battle").to!MapType; }
    auto description() { return _layer.properties.get("description", "No Description"); }
    auto mapName()     { return _data.properties.get("name", "Untitled"); }
    auto mapData()     { return _data; }
    auto layoutName()  { return _layer.properties.get("name", _layer.name); }
    auto objectData()  { return _data.layerTileData(_layer.name); }
  }

  int playerBaseCP(int playerIdx, int defaultCP) {
    auto key = baseCPformat.format(playerIdx);
    return key in _layer.properties ? _layer.properties[key].to!int : defaultCP;
  }

  string playerFaction(int playerIdx) {
    auto key = factionFormat.format(playerIdx);
    assert(key in _layer.properties, "skirmish layer must define " ~ key);
    return _layer.properties[key].capitalize;
  }
}

/// return map datas which support the given map type
auto mapLayoutsOfType(MapType type) {
  return _allLayouts.filter!(x => x.type == type);
}

auto fetchMapLayout(string name, string layoutName) {
  return _allLayouts.find!(x => x.mapName == name && x.layoutName == layoutName);
}

private:
MapLayout[] _allLayouts; /// every possible layout for every map

static this() {
  auto load = {
    foreach(entry ; Paths.mapDir.dirEntries(SpanMode.depth)) {
      auto map = entry.loadTiledMap();
      _allLayouts ~= map.layers.filter!(x => x.type == MapLayer.type.objectgroup)
        .map!(x => new MapLayout(map, x)).array;
    }
  };
  onInit(load);
}
