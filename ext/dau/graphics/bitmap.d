module dau.graphics.bitmap;

import std.string;
import std.conv;
import std.file : exists;
import dau.engine;
import dau.geometry.all;
import dau.graphics.color;

class Bitmap {
  @property {
    int width()  { return al_get_bitmap_width(_bitmap); }
    /// height of entire texture (px)
    int height() { return al_get_bitmap_height(_bitmap); }
    /// center of bitmap
    auto center() { return Vector2i(width / 2, height / 2); }
  }

  void draw(Vector2i pos, Vector2i origin = Vector2i.zero, Vector2f scale = Vector2f(1, 1),
      Color tint = Color.white, float angle = 0)
  {
    al_draw_tinted_scaled_rotated_bitmap(_bmp, // bitmap
        tint,                                  // color
        origin.x, origin.y,                    // frame center position
        pos.x, pos.y,                          // position to place center of frame at
        scale.x, scale.y,                      // x and y scale
        angle, 0);                             // rotation and flats
  }

  void drawRegion(Rec

  /*
  void draw(int row, int col, Vector2i pos, Vector2f scale = Vector2f(1, 1), Color tint = Color.white, float angle = 0) {
    assert(col >= 0 && col < numCols && row >= 0 && row < numRows);
    auto frame = Rect2i(col * frameWidth, row * frameHeight, frameWidth, frameHeight);
    al_draw_tinted_scaled_rotated_bitmap_region(_bmp, // bitmap
        frame.x, frame.y, frame.width, frame.height,  // bitmap region
        tint,                                         // color
        frameCenter.x, frameCenter.y,                 // frame center position
        pos.x, pos.y,                                 // position to place center of frame at
        scale.x, scale.y,                             // x and y scale
        angle, 0);                                    // rotation and flats
  }
  */

  private:
  ALLEGRO_BITMAP* _bmp;

  this(ALLEGRO_BITMAP *bmp) {
    _bmp = bmp;
  }
}

private Bitmap[string] _bitmapStore;

Bitmap getBitmap(string name) {
  assert(name in _bitmapStore, name ~ " could not be found in " ~ Paths.textureData);
  return _bitmapStore[name];
}

Bitmap registerBitmap(ALLEGRO_BITMAP* bmp, string name) {
  assert(name !in _bitmapStore, "cannot register bitmap " ~ name ~ " as it is already in texture store");
  return _bitmapStore[name] = new Bitmap(bmp);
}

Bitmap registerBitmap(ALLEGRO_BITMAP* bmp, string name, int frameWidth, int frameHeight) {
  assert(name !in _bitmapStore, "cannot register bitmap " ~ name ~ " as it is already in texture store");
  return _bitmapStore[name] = new Bitmap(bmp, frameWidth, frameHeight);
}

static this() { // automatically load a texture for each entry in the texture sheet config file
  auto textureData = loadConfigFile(Paths.textureData);
  auto textureDir = textureData.globals["texture_dir"];
  foreach (textureName, textureInfo; textureData.entries) {
    auto path = (textureDir ~ "/" ~ textureInfo["filename"]);
    assert(path.exists, format("texture path %s does not exist", path));
    auto bmp = al_load_bitmap(toStringz(path));
    assert(bmp, format("failed to load image %s", path));
    if ("frameSize" in textureInfo) {
      auto frameSize = split(textureInfo["frameSize"], ",");
      _bitmapStore[textureName] = new Bitmap(bmp, to!int(frameSize[0]), to!int(frameSize[1]));
    }
    else {
      _bitmapStore[textureName] = new Bitmap(bmp);
    }
  }
}

static ~this() { // destroy all bitmaps and clear texture store
  foreach (texture ; _bitmapStore) {
    al_destroy_bitmap(texture._bmp);
  }
  _bitmapStore = null;
}
