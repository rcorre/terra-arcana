module net.client;

import std.socket;

class NetworkClient {
  this(string ipAddress, ushort portNumber) {
    // TODO: try all addresses?
    this(new TcpSocket(getAddress(ipAddress, portNumber)[0]));
  }

  this(Socket socket) {
    _socket = socket;
  }

  bool send(void[] data) {
    auto ret = _socket.send(data);
    return ret == Socket.ERROR;
  }

  bool receive(out void[] buffer) {
    auto ret = _socket.receive(buffer);
    return ret == Socket.ERROR;
  }

  void close() {
    _socket.shutdown(SocketShutdown.BOTH);
    _socket.close();
  }

  private:
  Socket _socket;
}
