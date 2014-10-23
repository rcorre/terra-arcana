module dau.sound;

import std.string;
import std.conv;
import std.file;
import dau.allegro;
import dau.setup;

private enum {
  fileFormat = Paths.soundDir ~ "/%s.ogg", // TODO: support other extensions
  soundVolume = 1f // TODO: set in user preferences
}

void stopAllSounds() {
  al_stop_samples();
}

class SoundSample {
  enum Loop {
    no    = ALLEGRO_PLAYMODE.ALLEGRO_PLAYMODE_ONCE,
    yes   = ALLEGRO_PLAYMODE.ALLEGRO_PLAYMODE_LOOP,
    bidir = ALLEGRO_PLAYMODE.ALLEGRO_PLAYMODE_BIDIR
  }

  this(string key, Loop loop = Loop.no, float gain = 1, float speed = 1, float pan = 0) {
    _sample = loadSample(key);
    _loop   = loop;
    _gain   = gain;
    _speed  = speed;
    _pan    = pan;
  }

  void play() {
    float gain = _gain * soundVolume;
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
  Loop _loop;
}

void unloadSamples() {
  foreach(key, sample ; _samples) {
    al_destroy_sample(sample);
  }
  _samples = null;
}

private:
ALLEGRO_SAMPLE*[string] _samples;

auto loadSample(string key) {
  auto sample = _samples.get(key, null); // is it cached?
  if (sample !is null) {
    return sample;
  }
  // not cached -- load and cache for next time
  auto path = fileFormat.format(key);
  assert(path.exists, "sound file %s does not exist".format(path));
  sample = al_load_sample(path.toStringz);
  assert(sample !is null, "sound file %s exists but failed to load".format(path));
  _samples[key] = sample;
  return sample;
}

static this() {
  onShutdown({ unloadSamples(); });
}
