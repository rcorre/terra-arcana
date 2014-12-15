module battle.system.inputhint;

import dau.all;
import battle.battle;
import model.all;
import gui.inputhint;

class InputHintSystem : System!Battle {
  this(Battle b) {
    super(b);
  }

  void showHint(string key, string command) {
    if (Preferences.fetch.showInputHints) {
      _hints ~= scene.gui.addElement(new InputHint(key, command, cast(int) _hints.length));
    }
  }

  void hideHints() {
    foreach(hint ; _hints) {
      hint.transitionActive = false;
    }
    _hints = [];
  }

  override {
    void update(float time, InputManager input) { }
    void start() { }
    void stop() { }
  }

  private:
  InputHint[] _hints;
  bool _showHints;
}
