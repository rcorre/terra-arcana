module net.server;

import std.socket, std.stdio;
import net.client;

class NetworkServer {
  this(ushort portNumber) {
    _server = new TcpSocket();
    _server.setOption(SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, true);
    _server.bind(new InternetAddress(portNumber));
  }

  auto waitForClientConnection(int backlog = 1) {
    _server.listen(backlog);
    auto sock = _server.accept();
    return new NetworkClient(sock);
  }

  private:
  TcpSocket _server;
}
