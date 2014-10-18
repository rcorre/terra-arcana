module dau.setup;

alias InitFunction = void function();
alias ShutdownFunction = void function();

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
  fontDir     = "content/font",
  soundData   = "content/sounds.cfg",
  musicData   = "content/music.cfg",
  mapDir      = "data/maps",
  textureData = "data/textures.json",
  unitData    = "data/units.json",
}

void onInit(InitFunction fn) {
  _initializers ~= fn;
}

void onShutdown(ShutdownFunction fn) {
  _deInitializers ~= fn;
}

package:
void runSetupFunctions() {
  assert(!_setup, "tried to run setup functions twice");
  foreach(fn ; _initializers) {
    fn();
  }
  _setup = true;
}

void runShutdownFunctions() {
  assert(!_shutdown, "tried to run shutdown functions twice");
  foreach(fn ; _deInitializers) {
    fn();
  }
  _shutdown = true;
}

private:
bool _setup, _shutdown;
InitFunction[] _initializers;
ShutdownFunction[] _deInitializers;
