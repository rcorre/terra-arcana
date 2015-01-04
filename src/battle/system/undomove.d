module battle.system.undomove;

import std.container : SList;
import dau.all;
import battle.battle;
import model.all;

class UndoMoveSystem : System!Battle {
  this(Battle b) {
    super(b);
  }

  @property bool empty() { return _moves.empty; }

  void pushMove(Unit unit, Tile[] path) {
    _moves.insertFront(MoveRecord(unit, path));
  }

  auto popMove() {
    assert(!_moves.empty, "no undoable move to pop");
    auto record = _moves.front;
    _moves.removeFront();
    return record;
  }

  void clearMoves() {
    _moves.clear();
  }

  override {
    void update(float time, InputManager input) { }
    void start() { }
    void stop() { }
  }

  private:
  struct MoveRecord {
    Unit unit;
    Tile[] path;
  }

  SList!MoveRecord _moves;
}
