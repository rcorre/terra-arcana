module battle.system.network;

import dau.all;
import net.all;
import battle.battle;

class BattleNetworkSystem : System!Battle {
  alias MessageHandler = void delegate(NetworkMessage);
  this(Battle b, NetworkClient client) {
    super(b);
    active = (client !is null);
    clearHandler();
  }

  void setHandler(MessageHandler handler) {
    _handler = handler;
  }

  void clearHandler() {
    _handler = doNothing!MessageHandler;
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
