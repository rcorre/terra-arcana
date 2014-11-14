module dau.graphics.color;

import std.algorithm, std.conv, std.string, std.array;
import dau.allegro;
import dau.util.math;

alias color = Color;

struct Color {
  ALLEGRO_COLOR color;
  alias color this;

  //TODO: opAssign from ALLEGRO_COLOR?
  this(float r, float g, float b, float a = 1.0f) {
    color = ALLEGRO_COLOR(r, g, b, a);
  }

  this(ALLEGRO_COLOR color) {
    this.color = color;
  }

  static @property {
    Color white() { return Color(1, 1, 1, 1); }
    Color gray () { return Color(0.5, 0.5, 0.5, 1); }
    Color black() { return Color(0, 0, 0, 1); }
    Color red  () { return Color(1, 0, 0, 1); }
    Color green() { return Color(0, 1, 0, 1); }
    Color blue () { return Color(0, 0, 1, 1); }
    Color clear() { return Color(0, 0, 0, 0); }
  }
}

/// shortcut to create colors from unsigned byte values
Color ucolor(ubyte r, ubyte g, ubyte b, ubyte a = 255u) {
  return Color(r / 255f, g / 255f, b / 255f, a / 255f);
}

/// parse color from string of form "r,g,b" or "r,g,b,a" with values given as floats
Color parseColor(string csvSpec) {
  auto vals = csvSpec.splitter(",").map!(x => x.strip.to!float).array;
  switch (vals.length) {
    case 3:
      return color(vals[0], vals[1], vals[2]);
    case 4:
      return color(vals[0], vals[1], vals[2], vals[3]);
    default:
      assert(0, "failed to parse color from %s (%d entries)".format(csvSpec, vals.length));
  }
}

/// parse color from string of form "r,g,b" or "r,g,b,a" with values given as ubytes
Color parseUColor(string csvSpec) {
  auto vals = csvSpec.splitter(",").map!(x => x.strip.to!ubyte).array;
  switch (vals.length) {
    case 3:
      return ucolor(vals[0], vals[1], vals[2]);
    case 4:
      return ucolor(vals[0], vals[1], vals[2], vals[3]);
    default:
      assert(0, "failed to parse color from %s (%d entries)".format(csvSpec, vals.length));
  }
}

Color lerp(Color start, Color end, float factor) {
  auto r = dau.util.math.lerp(start.r, end.r, factor);
  auto g = dau.util.math.lerp(start.g, end.g, factor);
  auto b = dau.util.math.lerp(start.b, end.b, factor);
  auto a = dau.util.math.lerp(start.a, end.a, factor);
  return Color(r, g, b, a);
}

Color lerp(Color[] colors, float factor) {
  if (colors.length == 2) { 
    return lerp(colors[0], colors[1], factor); 
  }

  float colorTime = 1.0 / (colors.length - 1); // time for each color pair
  int idx = roundDown(factor * (colors.length - 1));
  if (idx < 0) {  // before first color
    return colors[0];  // return first
  }
  else if (idx >= colors.length - 1) {  // past last color
    return colors[$ - 1];  // return last
  }
  factor = (factor % colorTime) / colorTime;
  return lerp(colors[idx], colors[idx + 1], factor);
}

unittest {
  bool approxEqual(Color c1, Color c2) {
    import std.math : approxEqual;
    return c1.r.approxEqual(c2.r) &&
      c1.g.approxEqual(c2.g) &&
      c1.b.approxEqual(c2.b) &&
      c1.a.approxEqual(c2.a);
  }

  // float color with implied alpha
  auto c1 = Color(0.5, 1, 0.3);
  assert(approxEqual(c1, Color(0.5, 1, 0.3, 1)));

  // float color with specified alpha
  auto c2 = Color(0, 0, 0, 0.5);
  assert(approxEqual(c2, Color(0, 0, 0, 0.5)));

  // unsigned color with implied alpha
  auto c3 = ucolor(100, 255, 0);
  assert(approxEqual(c3, Color(100 / 255f, 1, 0, 1)));

  // unsigned color with specified alpha
  auto c4 = ucolor(0, 0, 255, 127);
  assert(approxEqual(c4, Color(0, 0, 1, 127 / 255f)));

  auto c5 = Color.black.lerp(Color.white, 0.5);
  assert(c5 == Color(0.5, 0.5, 0.5, 1));

  assert(lerp([Color.black, Color.white, Color.red], 0) == Color.black);
  assert(lerp([Color.black, Color.white, Color.red], 0.1) == Color(0.2, 0.2, 0.2));
  assert(lerp([Color.black, Color.white, Color.red], 0.5) == Color.white);
  assert(approxEqual(lerp([Color.black, Color.white, Color.red], 0.6), Color(1, 0.8, 0.8)));
  assert(approxEqual(lerp([Color.black, Color.white, Color.red], 1), Color.red));

  // parsing from strings
  assert(parseColor("1.0,0.5,0.2") == color(1.0, 0.5, 0.2));
  assert(parseColor("1.0, 0.5, 0.2") == color(1.0, 0.5, 0.2));
  assert(parseColor("1.0, 0.5, 0.2, 0.7") == color(1.0, 0.5, 0.2, 0.7));
  assert(parseColor("1.0,0.5,0.2,0.7") == color(1.0, 0.5, 0.2, 0.7));
  assert(parseColor("1,0,1") == color(1.0, 0.0, 1.0));
  assert(parseUColor("255, 128, 64") == ucolor(255, 128, 64));
}
