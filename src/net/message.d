module net.message;

import std.algorithm, std.array, std.string : format;
import model.all;

private enum {
  chatMessageSize = 40,
  factionNameSize = 20,
  unitKeySize = 20,
  tileCoordSize = 3,
  maxPathLength = 10
}

struct NetworkMessage {
  enum Type {
    closeConnection,
    chat,
    chooseFaction,
    cycleMap,
    startBattle,
    moveUnit,
    deployUnit,
    performAction
  }

  Type type;
  union {
    Chat chat;
    ChooseFaction chooseFaction;
    CycleMap cycleMap;

    MoveUnit moveUnit;
    DeployUnit deployUnit;
    PerformAction performAction;
  }

  this(Type type) {
    this.type = type;
  }

  static {
    auto makeCloseConnection() {
      return NetworkMessage(Type.closeConnection);
    }
    auto makeChat(string text) {
      assert(text.length <= chatMessageSize,
          "cannot send chat larger than %d".format(chatMessageSize));
      auto msg = NetworkMessage(Type.chat);
      msg.chat.text = text;
      return msg;
    }

    auto makeChooseFaction(Faction faction) {
      auto text = faction.name;
      assert(text.length <= factionNameSize,
          "faction name exceeds byte limit (%d/%d)".format(text.length, factionNameSize));
      auto msg = NetworkMessage(Type.chooseFaction);
      msg.chooseFaction.name = text;
      return msg;
    }

    auto makeCycleMap(bool next) {
      auto msg = NetworkMessage(Type.cycleMap);
      msg.cycleMap.next = next;
      return msg;
    }

    auto makeMoveUnit(Tile start, Tile[] path) {
      assert(path.length <= maxPathLength,
          "path exceeds size limit (%d/%d)".format(maxPathLength, path.length));
      auto msg = NetworkMessage(Type.moveUnit);
      msg.moveUnit.start = TileCoord(start);
      msg.moveUnit.pathLength = cast(ubyte) path.length;
      msg.moveUnit.path = path.map!(x => TileCoord(x)).array;
      return msg;
    }

    auto makeDeployUnit(string unitKey, Tile location) {
      assert(unitKey.length <= unitKeySize,
          "cannot send unit key larger than %d".format(unitKeySize));
      auto msg = NetworkMessage(Type.deployUnit);
      msg.deployUnit.location = TileCoord(location);
      msg.deployUnit.unitKey = unitKey;
      return msg;
    }

    auto makePerformAction(Tile start, Tile target, int actionNum) {
      auto msg = NetworkMessage(Type.performAction);
      msg.performAction.start = TileCoord(start);
      msg.performAction.target = TileCoord(target);
      msg.performAction.actionNum = cast(ubyte) actionNum;
      return msg;
    }
  }
}

private:
struct TileCoord {
  this(Tile tile) {
    row = tile.row;
    col = tile.col;
  }
  int row, col;
}

struct Chat {
  @property auto text() { return _text; }
  @property void text(string val) { _text[0 .. val.length] = val; }

  private char[chatMessageSize] _text;
}

struct ChooseFaction {
  @property auto name() { return _name; }
  @property void name(string val) { _name[0 .. val.length] = val; }

  private char[factionNameSize] _name;
}

struct CycleMap {
  bool next;
}

struct MoveUnit {
  TileCoord start;
  ubyte pathLength;
  TileCoord[maxPathLength] path;
}

struct DeployUnit {
  @property auto unitKey() { return _unitKey; }
  @property void unitKey(string val) { _unitKey[0 .. val.length] = val; }

  TileCoord location;

  private char[unitKeySize] _unitKey;
}

struct PerformAction {
  TileCoord start;
  TileCoord target;
  ubyte actionNum;
}
