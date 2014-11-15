module gui.deploymenu;

import std.string;
import std.conv;
import dau.all;
import model.all;

private enum {
  bgName            = "gui/deploy_menu",
  buttonName        = "gui/deploy_button",
  firstButtonOffset = Vector2i(0, 22),
}

/// bar that displays progress as discrete elements (pips)
class DeployMenu : Menu!(string, DeployButton) {
  this(const Faction faction, Vector2i offset, DeployButton.Action onClick, int cp) {
    // TODO: choose corner of unit based on screen positioning
    super(getGUIData("deployMenu"), offset, firstButtonOffset, onClick);
    auto buttonData = data.child["deployButton"];
    foreach(key ; faction.standardUnitKeys) {
      bool enabled = getUnitData(key).deployCost <= cp;
      addEntry(buttonData, key, enabled);
    }
  }
}

class DeployButton : MenuButton!string {
  this(GUIData data, string unitKey, Vector2i pos, Action onClick, bool enabled) {
    super(data, unitKey, pos, onClick, enabled);
    _dullShade = data["dullShade"].parseColor;
    _brightShade = data["brightShade"].parseColor;
    _disabledShade = data["disabledShade"].parseColor;
    _spriteOffset = data["spriteOffset"].parseVector!int;
    auto unit = getUnitData(unitKey);
    //addChild(new Icon(_animation, spriteOffset));
    addChild(new TextBox(data.child["text"], unit.name, data["nameOffset"].parseVector!int));
    addChild(new TextBox(data.child["text"], unit.deployCost, data["costOffset"].parseVector!int));
    sprite.tint = enabled ? _dullShade : _disabledShade;
    _animation = new Animation(unitKey, "idle", Animation.Repeat.loop);
  }

  override void onMouseEnter() {
    if (_enabled) {
      sprite.tint = _brightShade;
      _animation.start();
    }
  }

  override void onMouseLeave() {
    if (_enabled) {
      sprite.tint = _dullShade;
      _animation.stop();
    }
  }

  override void draw(Vector2i parentTopLeft) {
    super.draw(parentTopLeft);
    _animation.draw(area.topLeft + parentTopLeft);
  }

  private:
  Animation _animation;
  Vector2i _spriteOffset;
  Color _dullShade, _brightShade, _disabledShade;
}

Font _font;

static this() {
  onInit({ _font = Font("Mecha", 20); });
}
