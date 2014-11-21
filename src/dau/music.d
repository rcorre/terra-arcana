module dau.music;

import std.path, std.string;
import dau.setup;
import dau.allegro;

private enum {
  trackFormat = Paths.musicDir ~ "/%s.ogg",
  bufferCount = 4,
  sampleCount = 2048
}

void playMusicTrack(string name, bool loop = false) {
  stopCurrentMusicTrack();
  auto path = trackFormat.format(name);
  auto mixer = al_get_default_mixer();
  _stream = al_load_audio_stream(path.toStringz, bufferCount, sampleCount);

  assert(_stream !is null, "failed to load audio stream from " ~ path);
  assert(mixer !is null, "failed to get default mixer");

  if (loop) {
    bool ok = al_set_audio_stream_playmode(_stream, ALLEGRO_PLAYMODE.ALLEGRO_PLAYMODE_LOOP);
    assert(ok, "failed to set playmode to loop on music stream");
  }

  bool ok = al_attach_audio_stream_to_mixer(_stream, mixer);
  assert(ok, "failed to attach stream to mixer");
}

void stopCurrentMusicTrack() {
  if (_stream !is null) {
    al_destroy_audio_stream(_stream); // automatically calls al_detach_audio_stream
  }
  _stream = null;
}

private ALLEGRO_AUDIO_STREAM* _stream;

static this() {
  onShutdown({ stopCurrentMusicTrack(); });
}
