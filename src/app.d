import dau.engine;
import dau.scene;
import state.battle;

int main(char[][] args) {
  onInit({ currentScene = new Battle(); });
  return runGame();
}
