module gui.preferencescreen;

import std.string, std.array, std.algorithm;
import dau.all;
import model.all;
import title.title;
import title.state.showtitle;
import gui.displayselector;

private enum volumeIncrement = 0.1;

class PreferenceScreen : GUIElement {
  this(void delegate() goBack) {
    super(getGUIData("preferences"), Vector2i.zero);

    _preferences = Preferences.fetch();

    addChild(new TextBox(data.child["title"]));
    addChild(new TextBox(data.child["subtitle"]));
    addChild(new TextBox(data.child["musicText"]));
    addChild(new TextBox(data.child["soundText"]));

    _musicBar = new PipBar(data.child["musicVolumeBar"]);
    _soundBar = new PipBar(data.child["soundVolumeBar"]);

    addChildren(_musicBar, _soundBar);
    _musicBar.setVal(cast(int) (_preferences.musicVolume / volumeIncrement));
    _soundBar.setVal(cast(int) (_preferences.soundVolume / volumeIncrement));

    addChild(new Button(data.child["musicVolumeUp"], &musicVolumeUp));
    addChild(new Button(data.child["musicVolumeDown"], &musicVolumeDown));
    addChild(new Button(data.child["soundVolumeUp"], &soundVolumeUp));
    addChild(new Button(data.child["soundVolumeDown"], &soundVolumeDown));
    addChild(new Button(data.child["exit"], { _preferences.save(); goBack(); }));

    _inputHintsButton = addChild(new Button(data.child["toggleInputHints"], &toggleInputHints));
    _fullScreenButton = addChild(new Button(data.child["toggleFullScreen"], &toggleFullScreen));
    _resolutionButton = addChild(new Button(data.child["setResolution"], &setResolution));
    _inputHintsButton.text = "Show Input Hints: " ~ (_preferences.showInputHints ? "on" : "off");
    _fullScreenButton.text = "Full Screen: " ~ (_preferences.fullScreen ? "on" : "off");

    _selectResolution = addChild(new DisplaySelector(data.child["selectResolution"]));
  }

  private:
  Preferences _preferences;
  PipBar _musicBar, _soundBar;
  Button _inputHintsButton, _fullScreenButton, _resolutionButton;
  DisplaySelector _selectResolution;

  void musicVolumeUp() {
    _preferences.musicVolume = _preferences.musicVolume + volumeIncrement;
    _musicBar.setVal(cast(int) (_preferences.musicVolume / volumeIncrement));
    setMusicVolume(_preferences.musicVolume);
  }

  void musicVolumeDown() {
    _preferences.musicVolume = _preferences.musicVolume - volumeIncrement;
    _musicBar.setVal(cast(int) (_preferences.musicVolume / volumeIncrement));
    setMusicVolume(_preferences.musicVolume);
  }

  void soundVolumeUp() {
    _preferences.soundVolume = _preferences.soundVolume + volumeIncrement;
    _soundBar.setVal(cast(int) (_preferences.soundVolume / volumeIncrement));
  }

  void soundVolumeDown() {
    _preferences.soundVolume = _preferences.soundVolume - volumeIncrement;
    _soundBar.setVal(cast(int) (_preferences.soundVolume / volumeIncrement));
  }

  void toggleInputHints() {
    _preferences.showInputHints = !_preferences.showInputHints;
    _inputHintsButton.text = "Show Input Hints: " ~ (_preferences.showInputHints ? "on" : "off");
  }

  void toggleFullScreen() {
    _preferences.fullScreen = !_preferences.fullScreen;
    _fullScreenButton.text = "Full Screen: " ~ (_preferences.fullScreen ? "on" : "off");
  }

  void setResolution() {
    auto mode = _selectResolution.selection;
    _preferences.screenSizeX = mode.width;
    _preferences.screenSizeY = mode.height;
    resizeDisplay(mode.width, mode.height);
  }
}
