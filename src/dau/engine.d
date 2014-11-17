module dau.engine;

// library setup
pragma(lib, "dallegro5");
version(none)
{

}
else
{
	pragma(lib, "allegro");
	pragma(lib, "allegro_primitives");
	pragma(lib, "allegro_image");
	pragma(lib, "allegro_font");
	pragma(lib, "allegro_ttf");
	pragma(lib, "allegro_color");
	pragma(lib, "allegro_audio");
	pragma(lib, "allegro_acodec");
}

import dau.allegro;
import dau.setup;
import dau.scene;

// global variables
ALLEGRO_DISPLAY* mainDisplay;
ALLEGRO_EVENT_QUEUE* mainEventQueue;
ALLEGRO_TIMER* mainTimer;

/// pass FirstSceneType to instantiate first scene after allegro setup
int runGame(FirstSceneType)() {
  return al_run_allegro({
    // initialize
    al_init();

    al_set_new_display_option(ALLEGRO_DISPLAY_OPTIONS.ALLEGRO_VSYNC, 1, ALLEGRO_SUGGEST);
    mainDisplay = al_create_display(Settings.screenW, Settings.screenH);
    mainEventQueue = al_create_event_queue();
    mainTimer = al_create_timer(1.0 / Settings.fps);

    al_install_keyboard();
    al_install_mouse();
    al_install_joystick();
    al_install_audio();
    al_init_acodec_addon();
    al_init_image_addon();
    al_init_font_addon();
    al_init_ttf_addon();
    al_init_primitives_addon();

    al_reserve_samples(Settings.numAudioSamples);

    al_register_event_source(mainEventQueue, al_get_display_event_source(mainDisplay));
    al_register_event_source(mainEventQueue, al_get_keyboard_event_source());
    al_register_event_source(mainEventQueue, al_get_mouse_event_source());
    al_register_event_source(mainEventQueue, al_get_timer_event_source(mainTimer));
    al_register_event_source(mainEventQueue, al_get_joystick_event_source());

    with(ALLEGRO_BLEND_MODE)
    {
      al_set_blender(ALLEGRO_BLEND_OPERATIONS.ALLEGRO_ADD, ALLEGRO_ALPHA,
          ALLEGRO_INVERSE_ALPHA);
    }

    runSetupFunctions();

    al_start_timer(mainTimer); // start fps timer
    setScene(new FirstSceneType);

    while(_run) {
      bool frameTick = processEvents();
      if (frameTick) {
        mainUpdate();
        mainDraw();
      }
    }

    shutdownGame();

    return 0;
  });
}

void shutdownGame() {
  _run = false;
}

private:
bool _run = true;

// returns true if time to render next frame
bool processEvents() {
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
        shutdownGame();
        break;
      }
    case ALLEGRO_EVENT_KEY_DOWN:
      {
        switch(event.keyboard.keycode)
        {
          case ALLEGRO_KEY_ESCAPE:
            {
              shutdownGame();
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

void mainUpdate() {
  static float last_update_time = 0;
  float current_time = al_get_time();
  float delta = current_time - last_update_time;
  last_update_time = current_time;
  currentScene.update(delta);
}

void mainDraw() {
  currentScene.draw();
}
