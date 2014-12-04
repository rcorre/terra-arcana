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

private enum bool mapsToSelf(alias fun, T) = is(typeof(fun(T.init)) : T);

auto mapDict(alias keyFun, alias valFun, K, V)(V[K] aa) if 
  (mapsToSelf!(keyFun, K) && mapsToSelf!(valFun, V))
{
  V[K] result;
  foreach(k, v ; aa) {
    auto key = keyFun(k);
    auto val = valFun(v);
    result[key] = val;
  }
  return result;
}

unittest {
  auto aa = ["a": 1, "b": 2, "c": 3];
  auto aa1 = aa.mapDict!(x => x ~ "x", x => x + 3);
  assert(aa1 == ["ax": 4, "bx": 5, "cx": 6]);
}
