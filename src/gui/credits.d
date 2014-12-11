module gui.credits;

import std.string, std.conv, std.algorithm;
import dau.all;
import title.title;
import title.state.showtitle;

/// screen to show game credits
class CreditsScreen : GUIElement {
  this(Title title) {
    super(getGUIData("credits"), Vector2i.zero);

    addChildren!TextBox("title", "subtitle");
    addChild(new Button(data.child["back"], { title.states.setState(new ShowTitle); }));

    setPage(1);
  }

  private:
  GUIElement[] _entries;

  void setPage(int num) {
    foreach(entry ; _entries) {
      entry.active = false;
    }
    _entries = [];

    auto offset = data["firstEntryOffset"].parseVector!int;
    auto spacing = data["entrySpacing"].parseVector!int;

    string key = "page%d".format(num);
    assert(key in data.child, "no credits data for " ~ key);
    auto page = data.child[key];

    auto entryKeys = page.child.keys.filter!(x => x != "button");
    foreach(entryKey; entryKeys) {
      auto entry = addChild(new Icon(data.child["entryBackground"], offset));
      _entries ~= entry;

      auto entryData = page.child[entryKey];
      string text = "%s\n%s".format(entryData["text1"], entryData["text2"]);
      _entries ~= entry.addChild(new TextBox(data.child["entryText"], text));

      offset += spacing + Vector2i(0, entry.height);
    }

    auto buttonData = page.child["button"];
    auto nextPage = buttonData["nextPage"].to!int;
    buttonData["text"] = "page %d".format(num);
    _entries ~= addChild(new Button(page.child["button"], { setPage(nextPage); }));
  }
}
