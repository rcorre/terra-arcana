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
class DeployMenu : Menu!(Unit, DeployButton) {
  this(Unit[] units, Vector2i offset) {
    // TODO: choose corner of unit based on screen positioning
    super(new Sprite(bgName), offset, firstButtonOffset);
  }
}

class DeployButton : MenuButton!Unit {
  private enum {
    costOffset = Vector2i(172, 10),
  }

  this(Unit unit, Vector2i pos) {
    super(unit, new Sprite(buttonName), pos);
  }
}

Font _font;

static this() {
  onInit({ _font = Font("Mecha", 16); });
}
