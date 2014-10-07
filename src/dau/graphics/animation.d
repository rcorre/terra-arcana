module dau.graphics.animation;

import std.conv;
import dau.engine;
import dau.util.config;
import dau.graphics.texture;
import dau.graphics.sprite;
import dau.graphics.color;

class AnimatedSprite : Sprite {
  alias Action = void delegate();
  enum Repeat {
    no,          /// run only once
    loop,        /// loop back to beginning
    rebound      /// reverse animation direction
  }

  this(string textureName, string key, Repeat repeat = Repeat.no, Action onAnimationEnd = null) {
    auto texture = getTexture(textureName);
    super(texture);
    _startCol       = 0;
    _endCol         = texture.numCols;
    _row            = texture.rowByName(key);
    _frameTime      = texture.frameTime;
    _repeat         = repeat;
    _timer          = _frameTime;
    _onAnimationEnd = onAnimationEnd;
  }

  override void update(float time) {
    super.update(time);
    if (!_animate) { return; }

    _timer -= time;
    if (_timer < 0) {
      _timer = _frameTime;
      ++_col;
      if (_col == _endCol) {
        if (_onAnimationEnd) { _onAnimationEnd(); }
        final switch(_repeat) with(Repeat) {
          case no:
            _animate = false;
            _col = _endCol - 1;
            break;
          case loop:
            _col = _startCol;
            break;
          case rebound:
            assert(0, "AnimatedSprite.Repeat.rebound not implemented");
        }
      }
    }
  }

  @property isStopped() { return !_animate; }

  private:
  float _timer, _frameTime;
  int _startCol, _endCol;
  Repeat _repeat;
  bool _animate = true;
  Action _onAnimationEnd;
}
