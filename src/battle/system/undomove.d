module battle.system.undomove;

import std.container : SList;
import dau.all;
import battle.battle;
import model.all;

class UndoMoveSystem : System!Battle {
  this(Battle b) {
    super(b);
  }

  @property bool empty() { return _undos.empty; }

  void pushMove(Unit unit) {
    _undos.insertFront(UndoRecord(unit, unit.tile, unit.ap));
  }

  auto popMove() {
    assert(!_undos.empty, "no undoable move to pop");
    auto record = _undos.front;
    _undos.removeFront();
    return record;
  }

  void clearMoves() {
    if (!_undos.empty) {
      _undos.clear();
    }
  }

  override {
    void update(float time, InputManager input) { }
    void start() { }
    void stop() { }
  }

  private:
  struct UndoRecord {
    Unit unit;
    Tile tile;
    int ap;
  }

  SList!UndoRecord _undos;
}
