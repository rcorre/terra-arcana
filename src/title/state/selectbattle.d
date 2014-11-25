module title.state.selectbattle;

import dau.all;
import model.all;
import net.all;
import title.title;
import gui.battleselectionscreen;

/// player may click on a unit to issue orders
class SelectBattle : State!Title {
  this(NetworkClient client = null) {
    _client = client;
  }

  override {
    void enter(Title title) {
      title.gui.clear();
      title.gui.addElement(new BattleSelectionScreen(title, _client));
    }
  }

  private NetworkClient _client;
}
