module net.server;

import std.socket, std.stdio;
import net.client;

class NetworkServer {
  this(ushort portNumber) {
    _server = new TcpSocket();
    _server.setOption(SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, true);
    _server.bind(new InternetAddress(portNumber));
    _server.blocking = false;
    _server.listen(1); // 1 is backlog
  }

  auto waitForClientConnection() {
    try {
      auto sock = _server.accept();
      return new NetworkClient(sock);
    }
    catch(SocketException ex) {
      return null;
    }
  }

  void close() {
    _server.shutdown(SocketShutdown.BOTH);
    _server.close();
  }

  private:
  TcpSocket _server;
}
