module net.client;

import std.socket;

/// TODO: use multiple calls to send/receive if necessary (check returned byte count)
class NetworkClient {
  this(string ipAddress, ushort portNumber) {
    // TODO: try all addresses?
    this(new TcpSocket(getAddress(ipAddress, portNumber)[0]));
  }

  this(Socket socket) {
    _socket = socket;
  }

  void send(T)(T data) if (is(T == struct)) {
    auto ret = _socket.send((&data)[0 .. 1]);
    assert(ret != Socket.ERROR && ret == data.sizeof,  "failed to send data");
  }

  T receive(T)() if (is(T == struct)) {
    T buf;
    auto ret = _socket.receive((&buf)[0 .. 1]);
    assert(ret != Socket.ERROR && ret == data.sizeof, "failed to recieve data");
    return buf;
  }

  void close() {
    _socket.shutdown(SocketShutdown.BOTH);
    _socket.close();
  }

  private:
  Socket _socket;
}
