module dau.preferences;

import std.file, std.path;
import dau.setup;
import dau.util.jsonizer;
import dau.util.math;

enum ScreenMode {
  windowed,
  fullScreen,
  fullScreenWindow
}

class Preferences {
  mixin JsonizeMe;

  @jsonize {
    bool showInputHints   = true;
    ScreenMode screenMode = ScreenMode.windowed;
    int screenSizeX       = Settings.screenW;
    int screenSizeY       = Settings.screenH;
    @property {
      real soundVolume() { return _soundVolume; }
      real musicVolume() { return _musicVolume; }

      void soundVolume(real val) { _soundVolume = val.clamp(0f, 1f); }
      void musicVolume(real val) {
        _musicVolume = val.clamp(0f, 1f);
      }
    }
  }

  void save() {
    // ensure dir exists
    auto dir = Paths.preferences.dirName;
    if (!dir.exists) {
      mkdirRecurse(dir);
    }
    writeJSON(this, Paths.preferences);
  }

  static auto fetch() {
    if (_preferences is null) {
      if (exists(cast(string)Paths.preferences)) {
        _preferences = readJSON!Preferences(Paths.preferences);
      }
      else {
        _preferences = new Preferences;
      }
    }
    return _preferences;
  }


  private:
  real _soundVolume = 0.5;
  real _musicVolume = 0.5;
}

private:
Preferences _preferences;
