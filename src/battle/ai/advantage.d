module battle.ai.advantage;

import dau.all;

float getAdvantage(string unit, string other) {
  float all = 0;
  auto map = _advantageMap.get(unit, null);
  if (map !is null) {
    all += map.get("all", 0);
    if (other in map) {
      return all + map[other];
    }
  }
  map = _advantageMap.get(other, null);
  if (map !is null) {
    all -= map.get("all", 0);
    if (unit in map) {
      return all - map[unit];
    }
  }
  return all;
}

private:
float[string][string] _advantageMap;

static this() {
  _advantageMap = Paths.advantageData.readJSON!(float[string][string]);
}
