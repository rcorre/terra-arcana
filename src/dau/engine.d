module dau.engine;

import std.string, std.algorithm;
import dau.allegro;
import dau.setup;
import dau.scene;
import dau.preferences;

// global variables
ALLEGRO_DISPLAY* mainDisplay;
ALLEGRO_EVENT_QUEUE* mainEventQueue;
ALLEGRO_TIMER* mainTimer;

alias AllegroEventHandler = void delegate(ALLEGRO_EVENT);

void registerEventHandler(AllegroEventHandler handler, ALLEGRO_EVENT_TYPE type) {
  _eventHandlers[type] ~= handler;
}

/// pass FirstSceneType to instantiate first scene after allegro setup
int runGame(FirstSceneType)(string iconPath = null) {
  return al_run_allegro({
    // initialize
    al_init();

    al_set_new_display_option(ALLEGRO_DISPLAY_OPTIONS.ALLEGRO_VSYNC, 1, ALLEGRO_SUGGEST);
    if (Preferences.fetch.fullScreen) {
      createFullScreenDisplay();
    }
    else {
      mainDisplay = al_create_display(Settings.screenW, Settings.screenH);
    }
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

    if (iconPath !is null) {
      _icon = al_load_bitmap(iconPath.toStringz);
      al_set_display_icon(mainDisplay, _icon);
      onShutdown({ al_destroy_bitmap(_icon); });
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

    runShutdownFunctions();

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
    default:
  }
  foreach(handler ; _eventHandlers.get(event.type, null)) {
    handler(event);
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

auto findMaxDisplayMode() {
  ALLEGRO_DISPLAY_MODE mode, largest;
  for(int i = 0 ; i < al_get_num_display_modes() ; i++) {
    al_get_display_mode(0, &mode);
    if (mode.width > largest.width) {
      largest = mode;
    }
  }
  return largest;
}

void createFullScreenDisplay() {
  auto mode = findMaxDisplayMode();
  mainDisplay = al_create_display(mode.width, mode.height);
  float sx = cast(float) mode.width / Settings.screenW;
  float sy = cast(float) mode.height / Settings.screenH;
  float scale = min(sx, sy);
  ALLEGRO_TRANSFORM trans;
  al_identity_transform(&trans);
  al_scale_transform(&trans, scale, scale);
  al_use_transform(&trans);
}

private:
AllegroEventHandler[][ALLEGRO_EVENT_TYPE] _eventHandlers;
ALLEGRO_BITMAP* _icon;
