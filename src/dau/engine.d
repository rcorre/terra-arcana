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

// make all allegro functions available
public import allegro5.allegro;
public import allegro5.allegro_primitives;
public import allegro5.allegro_image;
public import allegro5.allegro_font;
public import allegro5.allegro_ttf;
public import allegro5.allegro_color;
public import allegro5.allegro_audio;
public import allegro5.allegro_acodec;

import dau.gamestate;
import dau.entity;
import dau.input;
import dau.gui.manager;

alias InitFunction = void function();
alias ShutdownFunction = void function();

// global variables
ALLEGRO_DISPLAY* mainDisplay;
ALLEGRO_EVENT_QUEUE* mainEventQueue;
ALLEGRO_TIMER* mainTimer;

/// global settings
enum Settings {
  fps     = 60,   /// frames-per-second of update/draw loop
  screenW = 800,  /// screen width
  screenH = 600,  /// screen height
  numAudioSamples = 4,  /// number of audio samples to reserve
}

/// paths to configuration files and content
enum Paths : string {
  bitmapDir   = "content/image",
  fontData    = "content/fonts.cfg",
  soundData   = "content/sounds.cfg",
  musicData   = "content/music.cfg",
  mapDir      = "data/maps",
  textureData = "data/textures.json",
  unitData    = "data/units.json",
}

// allegro initialization
int runGame() {
  return al_run_allegro({
    // initialize
    al_init();

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

    foreach(fn ; _initializers) {
      fn();
    }

    al_start_timer(mainTimer); // start fps timer

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
  foreach(fn ; _deInitializers) {
    fn();
  }
  _run = false;
}

void onInit(InitFunction fn) {
  _initializers ~= fn;
}

void onShutdown(ShutdownFunction fn) {
  _deInitializers ~= fn;
}

private:
InitFunction[] _initializers;
ShutdownFunction[] _deInitializers;
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
  updateEntities(delta);
  updateState(delta);
  updateGUI(delta);
  Input.update(delta);
}

void mainDraw() {
  al_clear_to_color(al_map_rgb(0,0,0));
  drawEntities();
  drawState();
  drawGUI();
  al_flip_display();
}
