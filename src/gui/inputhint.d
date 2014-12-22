module gui.inputhint;

import dau.all;

/// show unit AP and HP on the side of the screen
class InputHint : DynamicGUIElement {
  const string key, command;

  this(string key, string command, int index) {
    this.key = key;
    this.command = command;
    auto data = getGUIData("inputHint");
    auto pos = data["startPos"].parseVector!int;
    pos += data["spacing"].parseVector!int * index;

    super(data, pos, Anchor.center);
    area.y += sprite.height / 2;

    auto iconOffset = data["iconOffset"].parseVector!int;

    auto textData = data.child["text"];
    auto iconData = new GUIData;
    iconData["texture"] = "input";
    iconData["sprite"] = key;
    addChild(new Icon(iconData, textData, iconOffset, command));

    transitionActive = true;
  }

  override void update(float time) {
    super.update(time);
    if (!transitionActive && transitionAtStart) {
      active = false;
    }
  }
}
