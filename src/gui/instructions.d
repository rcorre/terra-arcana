module gui.instructions;

import dau.all;
import model.all;
import title.title;
import title.state.showtitle;

class InstructionScreen : GUIElement {
  this(Title title) {
    super(getGUIData("instructions"), Vector2i.zero);

    addChildren!Icon("wIcon", "aIcon", "sIcon", "dIcon", "qIcon", "eIcon", "spaceIcon", "lmbIcon",
        "rmbIcon", "hIcon");

    addChildren!TextBox("moveText", "chooseText", "skipText", "confirmText", "cancelText", "helpText");

    _title = title;
  }

  private:
  Title _title;
}
