module dau.graphics.bitmap;

import std.string;
import std.conv;
import std.file : exists;
import dau.engine;
import dau.geometry.all;
import dau.graphics.color;

private enum {
  bmpExtension = "png" // TODO: support for other types
}

struct Bitmap {
  @property {
    int width()  { return al_get_bitmap_width(_bmp); }
    /// height of entire texture (px)
    int height() { return al_get_bitmap_height(_bmp); }
    /// center of bitmap
    auto center() { return Vector2i(width / 2, height / 2); }
  }

  void draw(Vector2i pos, Vector2i origin = Vector2i.zero, Vector2f scale = Vector2f(1, 1),
      Color tint = Color.white, float angle = 0, Rect2i region = Rect2i(0, 0, width, height))
  {
    al_draw_tinted_scaled_rotated_bitmap_region(
        _bmp,                                            // bitmap
        region.x, region.y, region.width, region.height, // region
        tint,                                            // color
        origin.x, origin.y,                              // frame center position
        pos.x, pos.y,                                    // position to place center of frame at
        scale.x, scale.y,                                // x and y scale
        angle, 0);                                       // rotation and flats
  }

  private:
  ALLEGRO_BITMAP* _bmp;
}

/// try to load bitmap from Paths.bitmapDir/path.png
Bitmap loadBitmap(string path) {
  auto bmp = _bitmapStore.get(path, null);
  if (bmp is null) { // try to load and cache
    auto fullPath = "%s/%s.%s".format(Paths.bitmapDir, path, bmpExtension);
    assert(fullPath.exists, "bitmap file " ~ fullPath ~ " does not exist");
    bmp = al_load_bitmap(path.toStringz);
    assert(bmp !is null, fullPath ~ " exists, but loading bitmap failed");
    _bitmapStore[path] = bmp;
  }
  return Bitmap(bmp); // wrap ALLEGRO_BITMAP in D struct
}

/// destroy all bitmaps and clear texture store
void unloadAllBitmaps() {
  foreach (bitmap ; _bitmapStore) {
    al_destroy_bitmap(bitmap);
  }
  _bitmapStore = null;
}

static this() {
  onShutdown(&unloadAllBitmaps);
}

private ALLEGRO_BITMAP*[string] _bitmapStore;
