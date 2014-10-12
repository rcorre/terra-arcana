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

  void draw(Sprite sprite) {
    if (sprite !is null) {
      _sprites.insert(sprite);
    }
  }

  void render() {
    // use camera transform, store previous transform
    ALLEGRO_TRANSFORM prevTrans;
    al_copy_transform(&prevTrans, al_get_current_transform());
    al_use_transform(_camera.transform);

    foreach(sprite ; _sprites) {
      sprite.draw();
    }

    al_use_transform(&prevTrans); // restore old transform
    _sprites.clear();
  }

  private:
  alias SpriteStore = RedBlackTree!(Sprite, (a,b) => a.depth < b.depth);
  SpriteStore _sprites;
  Camera _camera;
}
