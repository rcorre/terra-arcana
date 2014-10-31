module model.obelisk;

import std.string : format;
import dau.all;
import model.tile;

class Obelisk : Entity {
  @property {
    int team() { return _team; }
  }

  this(Tile tile, int team, string faction) {
    auto sprite = new Animation("obelisk", faction, Animation.Repeat.loop);
    super(tile.center, sprite, "obelisk");
    _team = team;
  }

  void setTeam(int team, string faction) {
    _team = team;
    _sprite = new Animation("obelisk", faction, Animation.Repeat.loop);
  }

  private int _team;
}
