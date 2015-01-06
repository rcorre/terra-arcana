module gui.battletypescreen;

import dau.all;
import net.all;
import model.all;
import title.title;
import title.state.selectbattle;

class BattleTypeScreen : GUIElement {
  this(Title title, NetworkClient client, bool isHost) {
    super(getGUIData("battleTypeScreen"), Vector2i.zero);
    addChild(new TextBox(data.child["titleText"]));
    addChild(new TextBox(data.child["versionText"]));

    addChild(new Button(data.child["battle"],   { proceed(MapType.battle);   } ));
    addChild(new Button(data.child["skirmish"], { proceed(MapType.skirmish); } ));
    if (client is null) { // only provide tutorial for singleplayer
      addChild(new Button(data.child["tutorial"], { proceed(MapType.tutorial); } ));
    }
    addChild(new Button(data.child["exit"],     { title.states.popState(); } ));

    _title = title;
    _client = client;
    _isHost = isHost;
  }

  private:
  Title _title;
  private NetworkClient _client;
  private bool _isHost;

  void proceed(MapType type) {
    _title.states.pushState(new SelectBattle(type));
  }
}
