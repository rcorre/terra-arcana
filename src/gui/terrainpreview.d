module gui.terrainpreview;

import std.conv;
import dau.geometry.all;
import dau.graphics.all;
import dau.gui.all;
import model.all;

/// show terrain move cost and cover on the side of the screen
class TerrainPreview : DynamicGUIElement {
  this(Tile tile) {
    super(getGUIData("terrainPreview"));

    refresh(tile);
    transitionActive = true;
  }

  void refresh(Tile tile) {
    clear();

    addChild(new TextBox(data.child["name"], tile.name));
    addChild(new TextBox(data.child["cover"], tile.cover));

    string moveCost = (tile.moveCost == Tile.unreachable) ? "-" : tile.moveCost.to!string;
    addChild(new TextBox(data.child["moveCost"], moveCost));
  }

  override void update(float time) {
    super.update(time);
    if (!transitionActive && transitionAtStart) {
      active = false;
    }
  }
}
