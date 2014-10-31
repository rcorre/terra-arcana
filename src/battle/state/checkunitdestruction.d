module battle.state.checkunitdestruction;

import dau.all;
import model.all;
import battle.battle;
import battle.state.delay;

private enum {
  fadeTime = 0.5f,
  fadeSpectrum = [Color.black, Color.clear]
}

class CheckUnitDestruction : State!Battle {
  this(Unit unit) {
    _unit = unit;
  }

  override {
    void start(Battle b) {
      if (!_unit.isAlive) {
        _unit.destroy(fadeTime, fadeSpectrum);
        b.states.setState(new Delay(fadeTime, b =>  b.destroyUnit(_unit)));
      }
      else {
        b.states.popState();
      }
    }
  }

  private:
  Unit _unit;
}
