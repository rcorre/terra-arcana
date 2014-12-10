module gui.instructions;

import std.string, std.conv;
import dau.all;
import model.all;
import title.title;
import title.state.showtitle;

private enum textureFormat = "gui/instructions%d";
private enum pageDisplayFormat = "Page %d / %d";

class InstructionScreen : GUIElement {
  this(Title title) {
    super(getGUIData("instructions"), Rect2i(0, 0, Settings.screenW, Settings.screenH));

    _numPages = data["numPages"].to!int;
    _title = title;
    setPage(1);
  }

  private:
  Title _title;
  GUIElement _currentPage;
  int _pageNum;
  int _numPages;

  void setPage(int pageNum) {
    _pageNum = pageNum;

    if (_currentPage !is null) {
      _currentPage.active = false;
    }

    auto pageData = new GUIData;
    pageData["texture"] = textureFormat.format(pageNum);
    _currentPage = addChild(new GUIElement(pageData, Vector2i.zero));

    // navigation buttons
    if (_pageNum > 1) {
      _currentPage.addChild(new Button(data.child["prevPage"], { setPage(_pageNum - 1); }));
    }
    if (_pageNum < _numPages) {
      _currentPage.addChild(new Button(data.child["nextPage"], { setPage(_pageNum + 1); }));
    }

    // set up subject and page number textboxes
    string pageText = pageDisplayFormat.format(pageNum, _numPages);
    _currentPage.addChild(new TextBox(data.child["pageNumber"], pageText));
  }
}
