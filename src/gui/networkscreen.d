module gui.networkscreen;

import std.algorithm, std.range, std.file, std.path, std.array;
import dau.all;
import model.all;
import gui.factionmenu;
import battle.battle;
import title.title;
import title.state.showtitle;

enum mapFormat = Paths.mapDir ~ "/%s.json";

/// bar that displays progress as discrete elements (pips)
class NetworkScreen : GUIElement {
  this(Title title) {
    super(getGUIData("networkSetup"), Vector2i.zero);
    auto _ipInput = new TextInput(data.child["ipInput"]);
    addChild(_ipInput);
    addChild(new TextBox(data.child["titleText"]));
    addChild(new TextBox(data.child["networkText"]));
  }
}
