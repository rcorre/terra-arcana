module model.obelisk;

import std.string : format;
import dau.all;

class Obelisk : Entity {
  @property {
    int team() { return _team; }
  }

  this(Vector2i pos, int team, string faction) {
    auto sprite = new Animation("obelisk", faction, Animation.Repeat.loop);
    super(pos, sprite, "obelisk");
    _team = team;
  }

  void setTeam(int team, string faction) {
    _team = team;
    _sprite = new Animation("obelisk", faction, Animation.Repeat.loop);
  }

  private int _team;
}
