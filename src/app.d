import dau.engine;

private bool _run = true;        /// if false, shutdown game

int main(char[][] args) {
  return al_run_allegro({
      startGame();
      while(_run) {
        bool frameTick = process_event();
        if (frameTick) {
          main_update();
          main_draw();
        }
      }

      return 0;
  });
}

bool process_event() {
  ALLEGRO_EVENT event;
  al_wait_for_event(mainEventQueue, &event);
  switch(event.type)
  {
    case ALLEGRO_EVENT_TIMER:
      {
        if (event.timer.source == mainTimer) {
          return true;
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
  return false;
}

void main_update() {
  static float last_update_time = 0;
  float current_time = al_get_time();
  float delta = current_time - last_update_time;
  last_update_time = current_time;
}

void main_draw() {
  al_clear_to_color(al_map_rgb(0,0,0));
  al_flip_display();
}
