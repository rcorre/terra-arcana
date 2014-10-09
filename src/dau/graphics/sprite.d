module dau.graphics.sprite;

import std.string;
import std.conv;
import std.algorithm;
import dau.engine;
import dau.geometry.vector;
import dau.graphics.texture;
import dau.graphics.color;
import dau.util.config;
import dau.util.math;

/// displays a single frame of a texture
class Sprite {
  this(string textureName, string spriteName, int depth = 0) {
    _texture = getTexture(textureName);
    int idx = _texture.spriteIdx(spriteName);
    _row = idx / _texture.numCols;
    _col = idx % _texture.numCols;
    _depth = depth;
  }

  this(Texture spriteSheet, int spriteIdx = 0, int depth = 0) {
    _texture = spriteSheet;
    _row = spriteIdx / _texture.numCols;
    _col = spriteIdx % _texture.numCols;
    assert(_row >= 0 && _col >= 0 && _row < _texture.numRows && _col < _texture.numCols,
        format("sprite coord %d, %d is out of bounds", _row, _col));
    _depth = depth;
  }

  void flash(float time, Color flashColor) {
    _flashTimer = 0;
    _totalFlashTime = time;
    _colorSpectrum = [_tint, flashColor, _tint];
  }

  void fade(float time, Color color) {
    _flashTimer = 0;
    _totalFlashTime = time;
    _colorSpectrum = [_tint, color];
  }

  void fade(float time, Color[] colors) {
    _flashTimer = 0;
    _totalFlashTime = time;
    _colorSpectrum = _tint ~ colors; // append current color to start of spectrum
  }

  void shift(Vector2i offset, float speed) {
    _jiggleEffect = JiggleEffect(Vector2i.zero, offset, speed, 1);
  }

  void update(float time) {
    if (_totalFlashTime > 0) {
      _flashTimer += time;
      if (_flashTimer > _totalFlashTime) {
        _totalFlashTime = 0;
        _flashTimer = 0;
        _tint = _colorSpectrum[$ - 1];
      }
      else {
        _tint = lerp(_colorSpectrum, _flashTimer / _totalFlashTime);
      }
    }
    _jiggleEffect.update(time);
  }

  void draw() {
    auto adjustedPos = pos + _jiggleEffect.offset;
    _texture.draw(adjustedPos, _row, _col, scale, _tint, _angle);
  }

  @property {
    ref int depth() { return _depth; }
    ref auto pos() { return _pos; }
    /// width of the sprite after scaling (px)
    int width() { return cast(int) (_texture.frameWidth * scale.x); }
    /// height of the sprite after scaling (px)
    int height() { return cast(int) (_texture.frameHeight * scale.y); }
    /// width and height of sprite after scaling
    auto size() { return Vector2i(width, height); }
    /// tint color of the sprite
    auto tint()                    { return _tint; }
    auto tint(Color color) {
      _totalFlashTime = 0;
      return _tint = color;
    }
    /// get the rotation angle of the sprite (radians)
    auto angle()            { return _angle; }
    auto angle(float angle) { return _angle = angle; }
    /// the scale factor of the sprite
    auto scale()             { return _scaleFactor; }
    void scale(float scale)  { _scaleFactor = Vector2f(scale, scale); }
    void scale(Vector2f val) { _scaleFactor = val; }

    bool isJiggling() { return _jiggleEffect.active; }
    bool isFlashing() { return _totalFlashTime > 0; }
  }

  protected:
  int _row, _col;

  private:
  int _depth;
  Vector2i _pos;
  Texture _texture;
  Vector2f _scaleFactor = Vector2f(1, 1);
  float _angle          = 0;
  Color _tint           = Color.white;

  float _flashTimer, _totalFlashTime;
  Color[] _colorSpectrum;

  JiggleEffect _jiggleEffect;
}

private:

struct JiggleEffect {
  this(Vector2i start, Vector2i end, float frequency, int repetitions) {
    assert(frequency > 0, "cannot jiggle sprite with frequency <= 0");
    _start = start;
    _end = end;
    _period = 1 / frequency;
    _repetitions = repetitions;
  }

  void update(float time) {
    _lerpFactor += time / _period;
    if (_lerpFactor > 2) {
      _lerpFactor = 0;
      --_repetitions;
    }
  }

  @property {
    bool active() { return _repetitions > 0; }

    Vector2i offset() {
      if (!active) {
        return Vector2i.zero;
      }
      else if (_lerpFactor <= 1) {
        return lerp(_start, _end, _lerpFactor);
      }
      else if (_lerpFactor <= 2) {
        return lerp(_end, _start, _lerpFactor - 1);
      }
      else {
        assert(0, "internal failure : _lerpFactor > 2");
      }
    }
  }

  private:
  Vector2i _start, _end;
  float _period;
  float _lerpFactor = 0;
  int _repetitions = 0;
}