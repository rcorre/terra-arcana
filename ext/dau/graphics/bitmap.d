module dau.graphics.bitmap;

import std.string;
import std.conv;
import std.file : exists;
import dau.engine;
import dau.geometry.all;
import dau.graphics.color;

class Bitmap {
  @property {
    /// number of frame columns in the texture
    int numRows() { return height / frameHeight; }
    /// number of frame rows in the texture
    int numCols() { return width / frameWidth; }
    /// width of entire texture (px)
    int width()  { return _width; }
    /// height of entire texture (px)
    int height() { return _height; }
    /// width of a single texture frame (px)
    int frameWidth()  { return _frameWidth; }
    /// height of a single texture frame (px)
    int frameHeight() { return _frameHeight; }
    /// center position of a single frame (relative to the frame itself)
    Vector2i frameCenter() { return _frameCenter; }
  }

  void drawTopLeft(Vector2i pos, Vector2f scale = Vector2f(1, 1), Color tint = Color.white, float angle = 0) {
    al_draw_tinted_scaled_rotated_bitmap(_bmp, // bitmap
        tint,                                  // color
        0, 0,                                  // frame center position
        pos.x, pos.y,                          // position to place center of frame at
        scale.x, scale.y,                      // x and y scale
        angle, 0);                             // rotation and flats
  }

  void draw(Vector2i pos, Vector2f scale = Vector2f(1, 1), Color tint = Color.white, float angle = 0) {
    al_draw_tinted_scaled_rotated_bitmap(_bmp, // bitmap
        tint,                                  // color
        frameCenter.x, frameCenter.y,          // frame center position
        pos.x, pos.y,                          // position to place center of frame at
        scale.x, scale.y,                      // x and y scale
        angle, 0);                             // rotation and flats
  }

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

  void draw(int idx, Vector2i pos, Vector2f scale = Vector2f(1, 1), Color tint = Color.white, float angle = 0) {
    int row = idx / numCols;
    int col = idx % numCols;
    draw(row, col, pos, scale, tint, angle);
  }

  private:
  ALLEGRO_BITMAP* _bmp;
  const int _width, _height;
  const int _frameWidth, _frameHeight;
  const Vector2i _frameCenter;

  this(ALLEGRO_BITMAP *bmp, int frameWidth, int frameHeight) {
    _bmp         = bmp;
    _frameWidth  = frameWidth;
    _frameHeight = frameHeight;
    _width       = al_get_bitmap_width(bmp);
    _height      = al_get_bitmap_height(bmp);
    _frameCenter = Vector2i(frameWidth / 2, frameHeight / 2);
  }

  this(ALLEGRO_BITMAP *bmp) {
    _bmp         = bmp;
    _width       = al_get_bitmap_width(bmp);
    _height      = al_get_bitmap_height(bmp);
    _frameWidth  = _width;
    _frameHeight = _height;
    _frameCenter = Vector2i(frameWidth / 2, frameHeight / 2);
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
