module net.client;

import std.socket, std.string : format;

/// TODO: use multiple calls to send/receive if necessary (check returned byte count)
class NetworkClient {
  this(string ipAddress, ushort portNumber) {
    // TODO: try all addresses?
    this(new TcpSocket(getAddress(ipAddress, portNumber)[0]));
  }

  this(Socket socket) {
    _socket = socket;
    _socket.blocking = false;
  }

  @property bool isAlive() { return _socket.isAlive; }

  void send(T)(T data) if (is(T == struct)) {
    auto ret = _socket.send((&data)[0 .. 1]);
    assert(ret != Socket.ERROR && ret == data.sizeof,  "failed to send data");
  }

  bool receive(T)(out T buf) if (is(T == struct)) {
    auto ret = _socket.receive((&buf)[0 .. 1]);
    if (ret > 0) {
      assert(ret != Socket.ERROR, "socket error during receive");
      assert(ret == buf.sizeof, "expected %d bytes, got %d".format(buf.sizeof, ret));
      return true;
    }
    return false;
  }

  void close() {
    _socket.shutdown(SocketShutdown.BOTH);
    _socket.close();
  }

  private:
  Socket _socket;
}
