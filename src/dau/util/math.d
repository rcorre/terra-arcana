module dau.util.math;

import std.math : ceil, floor;
import std.algorithm : min, max;

/// add amount to start, but don't let it go past end
T approach(T, U, V)(T start, U end, V amount) {
  if (start < end) {
    return cast(T) min(start + amount, end);
  }
  else {
    return cast(T) max(start + amount, end);
  }
}

/// keep val between lower and upper
T clamp(T, U, V)(T val, U lower, V upper) if (is(typeof(min(V.init, max(U.init, T.init))) : T)) {
  return min(upper, max(lower, val));
}

T average(T)(T[] vals ...) if (is(typeof(((T.init + T.init) / T.init)) : T)) {
  return vals.sum / vals.length;
}

int roundUp(real val) {
  return cast(int) ceil(val);
}

int roundDown(real val) {
  return cast(int) floor(val);
}

/// linearly interpolate between start and end. factor is clamped between 0 (start) and 1 (end)
T lerp(T, U : real)(T start, T end, U factor) {
  factor = clamp(factor, 0, 1);
  return cast(T) (start + (end - start) * factor);
}

unittest {
  assert(5.clamp(0, 3) == 3);
  assert((-2).clamp(0, 3) == 0);
  assert(0.clamp(-5, 5) == 0);

  assert(clamp(0.5, 0, 1) == 0.5);
  assert(clamp(1.5, 0, 1) == 1);
  assert(clamp(-1.5, 0, 1) == 0);

  assert(lerp(0, 20, 0.5) == 10);
  assert(lerp(10, -10, 0.8) == -6);
}

/// vector lerp
unittest {
  import geometry.vector;

  auto v1 = Vector2i.Zero;
  auto v2 = Vector2i.UnitX * 10;
  assert(lerp(v1, v2, 0) == v1);
  assert(lerp(v1, v2, 0.5) == Vector2i(5, 0));
  assert(lerp(v1, v2, 1) == Vector2i(10, 0));

  auto v3 = Vector2f(3, 4);
  auto v4 = Vector2f(6, -3);
  assert(lerp(v3, v4, 0.5).approxEqual(Vector2f(4.5, 0.5)));
}
