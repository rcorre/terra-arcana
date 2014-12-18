module model.obelisk;

import std.string : format;
import dau.all;

class Obelisk : Entity {
  enum commandBonus = 1; /// command points awarded per obelisk held

  const int row, col;

  @property {
    int team() { return _team; }
  }

  this(Vector2i pos, int row, int col) {
    auto sprite = new Animation("obelisk", "neutral", Animation.Repeat.loop);
    super(pos, sprite, "obelisk");
    this.row = row;
    this.col = col;
  }

  void setTeam(int team, string faction) {
    _team = team;
    _sprite = new Animation("obelisk", faction, Animation.Repeat.loop);
  }

  private int _team;
}
