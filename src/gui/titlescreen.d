module gui.titlescreen;

import dau.all;
import model.all;
import title.title;

/// bar that displays progress as discrete elements (pips)
class TitleScreen : GUIElement {
  this() {
    super(getGUIData("titleScreen"), Vector2i.zero);
    addChild(new TextBox(data.child["titleText"]));
    addChild(new TextBox(data.child["versionText"]));

    addChild(new Button(data.child["startSinglePlayer"], null));
    addChild(new Button(data.child["startNetwork"], null));
    addChild(new Button(data.child["preferences"], null));
    addChild(new Button(data.child["credits"], null));
    addChild(new Button(data.child["exit"], null));
  }
}
