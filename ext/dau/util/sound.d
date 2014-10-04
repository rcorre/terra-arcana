module dau.util.sound;

import std.string;
import std.conv;
import std.file;
import dau.engine;
import dau.util.all;

enum Playmode {
  once  = ALLEGRO_PLAYMODE.ALLEGRO_PLAYMODE_ONCE,
  loop  = ALLEGRO_PLAYMODE.ALLEGRO_PLAYMODE_LOOP,
  bidir = ALLEGRO_PLAYMODE.ALLEGRO_PLAYMODE_BIDIR
}

void playSound(string key) {
  assert(key in _samples, "no sound sample named " ~ key);
  auto sample = new SoundSample(key);
  sample.play();
}

void stopAllSounds() {
  al_stop_samples();
}

class SoundSample {
  this(string key) {
    assert(key in _soundData.entries, "could not find sound data for " ~ key);
    auto data = _soundData.entries[key];
    _sample = _samples[key];
    assert(_sample !is null, "failed to load sound " ~ key);
    _gain   = to!float(data.get("gain", "1"));
    _speed  = to!float(data.get("speed", "1"));
    _pan    = to!float(data.get("pan", "0"));
    _loop   = to!Playmode(data.get("loop", "once"));
  }

  void play() {
    float gain = _gain * userPreferences.soundVolume / 100f;
    bool ok = al_play_sample(_sample, gain, _pan, _speed, _loop, &_id);
    assert(ok, "a sound sample failed to play");
  }

  void stop() {
    al_stop_sample(&_id);
  }

  static void stopAll() {
    al_stop_samples();
  }

  private:
  ALLEGRO_SAMPLE* _sample;
  ALLEGRO_SAMPLE_ID _id;
  float _gain, _speed, _pan;
  Playmode _loop;
}

private:
ALLEGRO_SAMPLE*[string] _samples;
ConfigData _soundData;
string _soundDir;

static this() {
  _soundData = loadConfigFile(Paths.soundData);
  _soundDir = _soundData.globals["soundDir"];
  foreach(key, data ; _soundData.entries) {
    auto path = (_soundDir ~ data["file"]);
    assert(path.exists, "no sound file at " ~ path);
    _samples[key] = al_load_sample(path.toStringz);
  }
}

static ~this() {
  foreach(key , sample ; _samples) {
    al_destroy_sample(sample);
  }
}
