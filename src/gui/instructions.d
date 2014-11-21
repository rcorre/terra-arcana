module gui.instructions;

import std.string;
import dau.all;
import model.all;
import title.title;
import title.state.showtitle;

private enum pageFormat = "page%d";

class InstructionScreen : GUIElement {
  this(Title title) {
    super(getGUIData("instructions"), Vector2i.zero);

    setPage(1);

    _title = title;
  }

  private:
  Title _title;
  int _pageNum;

  void setPage(int pageNum) {
    _pageNum = pageNum;
    clear();
    string name = pageFormat.format(pageNum);
    auto page = data.child[name];

    foreach(iconData ; page.child["icons"].child) {
      addChild(new Icon(iconData));
    }

    foreach(textData ; page.child["textBoxes"].child) {
      addChild(new TextBox(textData));
    }
  }

}
