module title.state.selectbattle;

import dau.all;
import model.all;
import net.all;
import title.title;
import gui.battleselectionscreen;

/// player may click on a unit to issue orders
class SelectBattle : State!Title {
  this(MapType mapType, NetworkClient client = null, bool isHost = false) {
    _mapType = mapType;
    _client = client;
    _isHost = isHost;
  }

  override {
    void enter(Title title) {
      title.gui.clear();
      title.gui.addElement(new BattleSelectionScreen(title, _mapType, _client, _isHost));
    }
  }

  private:
  MapType       _mapType;
  NetworkClient _client;
  bool          _isHost;
}
