/// helper methods for working with D ranges
module dau.util.range;

import std.array;

/// return range.front, using val as a default if range is empty
auto frontOr(R, T)(R range, T val) if (is(T : typeof(range.front)) && is(typeof(range.empty) : bool)) {
  return range.empty ? val : range.front;
}

unittest {
  import std.algorithm;
  auto a = [1, 2, 3, 4, 5];
  assert(a.find!(x => x > 3).frontOr(0) == 4);
  assert(a.find!(x => x > 5).frontOr(0) == 0);
}
