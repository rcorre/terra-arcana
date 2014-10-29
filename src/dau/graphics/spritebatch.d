module dau.graphics.spritebatch;

import std.container;
import dau.allegro;
import dau.engine;
import dau.geometry.all;
import dau.graphics.sprite;
import dau.graphics.camera;

// TODO: group textures and use al_hold_bitmap_drawing
class SpriteBatch {
  this() {
    _sprites = new SpriteStore;
  }

  void draw(Sprite sprite, Vector2i pos) {
    if (sprite !is null) {
      Entry entry;
      entry.sprite = sprite;
      entry.pos = pos;
      _sprites.insert(entry);
    }
  }

  void render(Camera camera) {
    // use camera transform, store previous transform
    ALLEGRO_TRANSFORM prevTrans;
    int x, y, w, h; // prev clipping rect
    al_copy_transform(&prevTrans, al_get_current_transform());
    al_get_clipping_rectangle(&x, &y, &w, &h);
    al_use_transform(camera.transform);
    al_set_clipping_rectangle(0 ,0, camera.clipWidth, camera.clipHeight);

    foreach(entry ; _sprites) {
      entry.sprite.draw(entry.pos);
    }

    al_use_transform(&prevTrans); // restore old transform
    al_set_clipping_rectangle(x, y, w, h);
    _sprites.clear();
  }

  private:
  struct Entry {
    Sprite sprite;
    Vector2i pos;
  }

  // true indicates: allow duplicates
  alias SpriteStore = RedBlackTree!(Entry, (a,b) => a.sprite.depth < b.sprite.depth, true);
  SpriteStore _sprites;
}
