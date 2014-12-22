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

  void setHint(int idx, string key, string command) {
    if (Preferences.fetch.showInputHints) {
      if (idx >= _hints.length) {
        auto hint = scene.gui.addElement(new InputHint(key, command, cast(int) _hints.length));
        _hints ~= hint;
      }
      else {
        if (_hints[idx] !is null) { 
          if (_hints[idx].key == key && _hints[idx].command == command) { 
            return; 
          }
          _hints[idx].active = false; 
        }
        auto hint = scene.gui.addElement(new InputHint(key, command, idx));
        _hints[idx] = hint;
      }
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
