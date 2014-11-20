module gui.preferencescreen;

import dau.all;
import model.all;
import title.title;
import title.state.showtitle;

class PreferenceScreen : GUIElement {
  this(Title title) {
    super(getGUIData("preferences"), Vector2i.zero);
    addChild(new TextBox(data.child["musicText"]));
    addChild(new TextBox(data.child["soundText"]));

    addChild(new PipBar(data.child["musicVolumeBar"]));
    addChild(new PipBar(data.child["soundVolumeBar"]));

    addChild(new Button(data.child["musicVolumeUp"], &musicVolumeUp));
    addChild(new Button(data.child["musicVolumeDown"], &musicVolumeDown));
    addChild(new Button(data.child["soundVolumeUp"], &soundVolumeUp));
    addChild(new Button(data.child["soundVolumeDown"], &soundVolumeDown));

    _title = title;
  }

  private:
  Title _title;

  void musicVolumeUp() {
  }

  void musicVolumeDown() {
  }

  void soundVolumeUp() {
  }

  void soundVolumeDown() {
  }

  void exitButton() {
    _title.states.setState(new ShowTitle);
  }
}
