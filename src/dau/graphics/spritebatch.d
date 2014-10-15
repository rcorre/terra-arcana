module dau.graphics.spritebatch;

import std.container;
import dau.engine;
import dau.geometry.all;
import dau.graphics.sprite;
import dau.graphics.camera;

// TODO: group textures and use al_hold_bitmap_drawing
class SpriteBatch {
  this(Camera camera) {
    _camera = camera;
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

  void render() {
    // use camera transform, store previous transform
    ALLEGRO_TRANSFORM prevTrans;
    al_copy_transform(&prevTrans, al_get_current_transform());
    al_use_transform(_camera.transform);

    foreach(entry ; _sprites) {
      entry.sprite.draw(entry.pos);
    }

    al_use_transform(&prevTrans); // restore old transform
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
  Camera _camera;
}
