module dau.graphics.texture;

import std.string;
import std.conv;
import std.algorithm;
import std.file : exists;
import dau.engine;
import dau.util.jsonizer;
import dau.geometry.all;
import dau.graphics.color;

private enum {
  pathFormat = Paths.bitmapDir ~ "/%s.png"
}

class Texture {
  const int frameWidth, frameHeight;
  const float frameTime;
  @property {
    /// width of entire bitmap
    int width() { return al_get_bitmap_width(_bmp); }
    /// height of entire bitmap
    int height() { return al_get_bitmap_height(_bmp); }
    /// number of frame columns in the texture
    int numRows() { return height / frameHeight; }
    /// number of frame rows in the texture
    int numCols() { return width / frameWidth; }
    /// center position of a single frame (relative to the frame itself)
    Vector2i frameCenter() { return Vector2i(frameWidth / 2, frameHeight / 2); }
  }

  int rowByName(string name) {
    int row = cast(int) _rows.countUntil(name);
    debug {
      import std.stdio;
      writeln(name ~ " is at row " ~ row.to!string ~ " in " ~ _rows.to!string);
    }
    assert(row >= 0, "no row named " ~ name);
    return row;
  }

  int spriteIdx(string name) {
    int idx = cast(int) _sprites.countUntil(name);
    assert(idx < numRows * numCols, "no sprite named " ~ name ~ " found");
    return idx;
  }

  void drawTopLeft(Vector2i pos, Vector2f scale = Vector2f(1, 1), Color tint = Color.white,
      float angle = 0)
  {
    al_draw_tinted_scaled_rotated_bitmap(_bmp, // bitmap
        tint,                                  // color
        0, 0,                                  // frame center position
        pos.x, pos.y,                          // position to place center of frame at
        scale.x, scale.y,                      // x and y scale
        angle, 0);                             // rotation and flats
  }

  void draw(Vector2i pos, Vector2f scale = Vector2f(1, 1), Color tint = Color.white,
      float angle = 0)
  {
    al_draw_tinted_scaled_rotated_bitmap(_bmp, // bitmap
        tint,                                  // color
        frameCenter.x, frameCenter.y,          // frame center position
        pos.x, pos.y,                          // position to place center of frame at
        scale.x, scale.y,                      // x and y scale
        angle, 0);                             // rotation and flats
  }

  void draw(Vector2i pos, int row = 0, int col = 0, Vector2f scale = Vector2f(1, 1),
      Color tint = Color.white, float angle = 0)
  {
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

  void draw(Vector2i pos, int idx = 0, Vector2f scale = Vector2f(1, 1), Color tint = Color.white,
      float angle = 0)
  {
    int row = idx / numCols;
    int col = idx % numCols;
    draw(pos, row, col, scale, tint, angle);
  }

  private:
  ALLEGRO_BITMAP* _bmp;
  const string[] _rows, _sprites;

  this(ALLEGRO_BITMAP *bmp, TextureData data)
  {
    _bmp             = bmp;
    this.frameWidth  = data.frameSize;
    this.frameHeight = data.frameSize;
    this.frameTime   = data.frameTimeMs / 1000f;
    _rows            = data.rows;
    _sprites         = data.sprites;
  }
}

Texture getTexture(string name) {
  assert(name in _textureStore, name ~ " could not be found in " ~ Paths.textureData);
  return _textureStore[name];
}

private:

static this() { // automatically load a texture for each entry in the texture sheet config file
  onInit(&loadTextures);
  onShutdown(&unloadTextures);
}

void loadTextures() {
  auto textureData = Paths.textureData.readJSON!(TextureData[]);
  foreach (data ; textureData) {
    foreach(name ; data.sheets) {
      auto path = pathFormat.format(name);
      assert(path.exists, format("texture path %s does not exist", path));
      auto bmp = al_load_bitmap(path.toStringz);
      assert(bmp, format("failed to load image %s", path));

      _textureStore[name] = new Texture(bmp, data);
    }
  }
}

void unloadTextures() { // destroy all bitmaps and clear texture store
  foreach (texture ; _textureStore) {
    al_destroy_bitmap(texture._bmp);
  }
  _textureStore = null;
}

Texture[string] _textureStore;

class TextureData {
  mixin JsonizeMe;
  @jsonize {
    string[] sheets;
    string[] sprites;
    string[] rows;
    int frameSize;
    int frameTimeMs;
  }
}
