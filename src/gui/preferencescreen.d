module gui.preferencescreen;

import dau.all;
import model.all;
import title.title;
import title.state.showtitle;

private enum volumeIncrement = 0.1;

class PreferenceScreen : GUIElement {
  this(Title title) {
    super(getGUIData("preferences"), Vector2i.zero);

    _preferences = Preferences.fetch();

    addChild(new TextBox(data.child["titleText"]));
    addChild(new TextBox(data.child["preferencesText"]));
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
    addChild(new Button(data.child["exit"], &exitButton));

    _title = title;
  }

  private:
  Title _title;
  Preferences _preferences;
  PipBar _musicBar, _soundBar;

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

  void exitButton() {
    _title.states.setState(new ShowTitle);
    _preferences.save();
  }
}
