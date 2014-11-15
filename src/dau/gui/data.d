module dau.gui.data;

import dau.setup;
import dau.util.jsonizer;

class GUIData {
  mixin JsonizeMe;
  alias properties this;
  @jsonize {
    string[string] properties;
    GUIData[string] child;
  }
}

auto getGUIData(string key) {
  return _data.get(key, new GUIData);
}

private:
GUIData[string] _data;

static this() {
  onInit({ _data = Paths.guiData.readJSON!(GUIData[string]); });
}
