module title.state.selectbattle;

import dau.all;
import model.all;
import net.all;
import title.title;
import gui.battleselectionscreen;

/// player may click on a unit to issue orders
class SelectBattle : State!Title {
  this(NetworkClient client = null, bool isHost = false) {
    _client = client;
    _isHost = isHost;
  }

  override {
    void enter(Title title) {
      title.gui.clear();
      title.gui.addElement(new BattleSelectionScreen(title, _client, _isHost));
    }
  }

  private NetworkClient _client;
  private bool _isHost;
}
