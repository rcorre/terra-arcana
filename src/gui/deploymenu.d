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
    super(new Sprite(bgName), offset, firstButtonOffset, onClick);
    foreach(key ; faction.standardUnitKeys) {
      bool enabled = getUnitData(key).deployCost <= cp;
      addEntry(key, enabled);
    }
  }
}

class DeployButton : MenuButton!string {
  private enum {
    costOffset    = Vector2i(172, 10),
    spriteOffset  = Vector2i(0, 0),
    nameOffset    = Vector2i(48, 4),
    brightShade   = Color(1, 1, 1, 0.9),
    dullShade     = Color(0.9, 0.9, 0.9, 0.6),
    disabledShade = color(0.5, 0.5, 0.5, 0.5),
  }

  this(string unitKey, Vector2i pos, Action onClick, bool enabled) {
    _animation = new Animation(unitKey, "idle", Animation.Repeat.loop);
    auto sprite = new Sprite(buttonName);
    sprite.tint = enabled ? dullShade : disabledShade;
    super(unitKey, sprite, pos, onClick, enabled);
    auto data = getUnitData(unitKey);
    addChild(new Icon(_animation, spriteOffset));
    addChild(new TextBox(data.name, _font, nameOffset));
    addChild(new TextBox(data.deployCost, _font, costOffset));
  }

  override void onMouseEnter() {
    if (_enabled) {
      sprite.tint = brightShade;
      _animation.start();
    }
  }

  override void onMouseLeave() {
    if (_enabled) {
      sprite.tint = dullShade;
      _animation.stop();
    }
  }

  private:
  Animation _animation;
}

Font _font;

static this() {
  onInit({ _font = Font("Mecha", 20); });
}
