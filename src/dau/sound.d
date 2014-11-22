module dau.sound;

import std.string, std.conv, std.file, std.path, std.typecons;
import dau.allegro;
import dau.setup;
import dau.preferences;

private enum {
  fileFormat = Paths.soundDir ~ "/%s.ogg", // TODO: support other extensions
}

abstract class AudioSample {
  abstract void play();
  abstract void stop();
}

class SoundSample : AudioSample {
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

  override void play() {
    float gain = _gain * Preferences.fetch().soundVolume;
    bool ok = al_play_sample(_sample, gain, _pan, _speed, _loop, &_id);
    assert(ok, "a sound sample failed to play");
  }

  override void stop() {
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

auto nullAudio() {
  return new BlackHole!AudioSample();
}

void preloadSoundSamples() {
  foreach(entry ; Paths.soundDir.dirEntries("*.ogg", SpanMode.shallow)) {
    loadSample(entry.baseName(".ogg"));
  }
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
  onInit({ preloadSoundSamples(); });
  onShutdown({ unloadSamples(); });
}
