module battle.system.inputhint;

import std.string, std.algorithm;
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
    if (!Preferences.fetch.showInputHints) { return; } // hints disabled

    if (idx >= _hints.length) {
      _hints.length = idx + 1;
    }
    auto current = _hints[idx];
    if (current is null) {
      _hints[idx] = scene.gui.addElement(new InputHint(key, command, idx));
    }
    else if (current.command != command || current.key != key) {
      current.active = false;
      _hints[idx] = scene.gui.addElement(new InputHint(key, command, idx));
    }
  }

  void clearHint(int idx) {
    if (idx >= _hints.length) { return; }
    auto hint = _hints[idx];
    if (hint !is null) {
      hint.active = false;
      _hints[idx] = null;
    }
  }

  void hideHints() {
    foreach(hint ; _hints.filter!(x => x !is null)) {
      hint.active = false;
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
