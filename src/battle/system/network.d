module battle.system.network;

import std.algorithm;
import dau.all;
import net.all;
import model.all;
import battle.battle;

class BattleNetworkSystem : System!Battle {
  alias MessageHandler = void delegate(NetworkMessage);
  this(Battle b, NetworkClient client) {
    super(b);
    _client = client;
    active = (client !is null);
    clearHandler();
  }

  void setHandler(MessageHandler handler) {
    _handler = handler;
  }

  void clearHandler() {
    _handler = doNothing!MessageHandler;
  }

  void broadcastEndTurn() {
    if (_client !is null) { _client.send(NetworkMessage(NetworkMessage.Type.endTurn)); }
  }

  void broadcastMove(Unit unit, Tile[] path) {
    if (_client !is null) { _client.send(NetworkMessage.makeMove(unit.tile, path)); }
  }

  void broadcastAction(Unit actor, Tile target, int actionNum) {
    auto start = actor.tile;
    if (_client !is null) { _client.send(NetworkMessage.makeAct(start, target, actionNum)); }
  }

  void broadcastDeploy(string key, Tile place) {
    if (_client !is null) { _client.send(NetworkMessage.makeDeploy(key, place)); }
  }

  override {
    void update(float time, InputManager input) {
      NetworkMessage msg;
      if (_client.receive(msg)) {
      }
    }

    void start() {
    }

    void stop() {
    }
  }

  private:
  NetworkClient _client;
  MessageHandler _handler;

  void processMessage(NetworkMessage msg) {
    // TODO: handle chat here
    switch (msg.type) with (NetworkMessage.Type) {
      case closeConnection:
        //TODO
        break;
      case chat:
        //TODO
        break;
      default:
        _handler(msg);
    }
  }
}
