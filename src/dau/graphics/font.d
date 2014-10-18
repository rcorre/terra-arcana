module dau.graphics.font;

import std.string;
import std.conv;
import std.range;
import std.algorithm;
import dau.allegro;
import dau.setup;
import dau.geometry.all;
import dau.graphics.color;

enum fileFormat = Paths.fontDir ~ "/%s.ttf"; // TODO: support other formats

/// TODO: should I use std.ascii.newline instead of '\n'?
/// Wrapper around ALLEGRO_FONT
struct Font {
  this(string name, int size) {
    if (name !in _fontStore || size !in _fontStore[name]) {
      auto file = fileFormat.format(name);
      auto font = al_load_font(file.toStringz, size, 0); // 0 for flags
      assert(font !is null, "could not load font " ~ name ~ " from " ~ file);
      _fontStore[name][size] = font;
    }
    _font = _fontStore[name][size];
  }

  int heightOf(string text) {
    auto lines = text.splitter('\n');
    return al_get_font_line_height(_font) * (cast(int) lines.count("\n") + 1);
  }

  int widthOf(string text) {
    auto lines = text.splitter('\n');
    return reduce!((a, b) => a + al_get_text_width(_font, b.toStringz))(0, lines);
  }

  /// draw text at the given vector position in the given color
  void draw(string text, Vector2i topLeft, Color color = Color.black) {
    auto lines = text.splitter('\n');
    foreach(line ; lines) {
      al_draw_text(_font, color, topLeft.x, topLeft.y, 0, text.toStringz);
      topLeft.y += al_get_font_line_height(_font);
    }
  }

  /// return an array of text lines wrapped at the specified width (in pixels). Split text elements on whitespace
  string[] wrapText(string text, int maxLineWidth) {
    string currentLine;
    string[] lines;
    foreach(word ; filter!(s => !s.empty)(splitter(text))) {
      if (widthOf(currentLine ~ word) > maxLineWidth) {
        lines ~= stripRight(currentLine);
        currentLine = word ~ " ";
      }
      else {
        currentLine ~= (word ~ " ");
      }
    }
    return lines ~ currentLine; // make sure to append last line
  }

  private:
  ALLEGRO_FONT* _font;
}

private ALLEGRO_FONT*[int][string] _fontStore; // indexed by [name][size]
