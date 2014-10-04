module dau.util.preferences;

import std.file;
import std.path;
import dau.util.jsonizer;

class Preferences {
  mixin JsonizeMe;
  @jsonize {
    int musicVolume = 50;
    int soundVolume = 50;
    bool showInputIcons = true;
  }
}

Preferences userPreferences;

private:
enum prefPath = "./save/prefs.json";

static this() {
  if (prefPath.exists) {
    userPreferences = prefPath.readJSON!Preferences;
  }
  else {
    userPreferences = new Preferences;
  }
}

static ~this() {
  if (!prefPath.dirName.exists) {
    mkdir(prefPath.dirName);
  }
  userPreferences.writeJSON(prefPath);
}
