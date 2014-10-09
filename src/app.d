import dau.engine;
import dau.gamestate;
import state.battle;

int main(char[][] args) {
  onInit({ pushState(new Battle()); });
  return runGame();
}
