import std.file;
import allegro;
import state.title;
import state.gamestate;
import util.config;
import model.character;

private bool _run = true;        /// if false, shutdown game
private bool _frameTick = false; /// if true, time for an update/draw cycle

private GameState _currentState;

int main(char[][] args) {
  _currentState = new Title();

  return al_run_allegro({
      al_hide_mouse_cursor(display);
      while(_run) {
        process_event();
        if (_frameTick) {
          main_update();
          main_draw();
          _frameTick = false;
        }
      }

      return 0;
  });
}

void process_event() {
  ALLEGRO_EVENT event;
  al_wait_for_event(event_queue, &event);
  switch(event.type)
  {
    case ALLEGRO_EVENT_TIMER:
      {
        if (event.timer.source == frame_timer) {
          _frameTick = true;
        }
        break;
      }
    case ALLEGRO_EVENT_DISPLAY_CLOSE:
      {
        _run = false;
        break;
      }
    case ALLEGRO_EVENT_KEY_DOWN:
      {
        switch(event.keyboard.keycode)
        {
          case ALLEGRO_KEY_ESCAPE:
            {
              _run = false;
              break;
            }
          default:
        }
        break;
      }
    default:
  }
  _currentState.handleEvent(event);
}

void main_update() {
  static float last_update_time = 0;
  float current_time = al_get_time();
  float delta = current_time - last_update_time;
  last_update_time = current_time;
  auto newState = _currentState.update(delta);
  if (newState) {
    _currentState = newState;
  }
}

void main_draw() {
  al_clear_to_color(al_map_rgb(0,0,0));
  _currentState.draw();
  al_flip_display();
}
