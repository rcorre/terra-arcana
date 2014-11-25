module net.message;

import std.algorithm, std.array, std.string : format;
import model.all;

private enum {
  chatMessageSize = 40,
  factionNameSize = 20,
  mapNameSize     = 20,
  unitKeySize     = 20,
  tileCoordSize   = 3,
  maxPathLength   = 10
}

struct NetworkMessage {
  enum Type {
    closeConnection,
    chat,
    chooseFaction,
    chooseMap,
    startBattle,
    moveUnit,
    deployUnit,
    performAction
  }

  Type type;
  union {
    Chat chat;
    ChooseFaction chooseFaction;
    ChooseMap chooseMap;

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

    auto makeChooseMap(string name) {
      auto msg = NetworkMessage(Type.chooseMap);
      msg.chooseMap.name = name;
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
/// send a string across a socket
struct NetString(size_t MaxLen) { 
  alias str this;

  void opAssign(string s) {
    assert(s.length <= MaxLen, "length %d exceeds NetString capacity %d".format(s.length, MaxLen));
    _str[0 .. s.length] = s;
    _strLen = s.length;
  }

  @property string str() { return _str[0 .. _strLen].dup; }

  private char[MaxLen] _str;
  private size_t _strLen;
}

struct TileCoord {
  this(Tile tile) {
    row = tile.row;
    col = tile.col;
  }
  int row, col;
}

struct Chat {
  NetString!chatMessageSize text;
}

struct ChooseFaction {
  NetString!factionNameSize name;
}

struct ChooseMap {
  NetString!mapNameSize name;
}

struct MoveUnit {
  TileCoord start;
  ubyte pathLength;
  TileCoord[maxPathLength] path;
}

struct DeployUnit {
  TileCoord location;
  NetString!unitKeySize unitKey;
}

struct PerformAction {
  TileCoord start;
  TileCoord target;
  ubyte actionNum;
}
