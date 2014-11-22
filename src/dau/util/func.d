module dau.util.func;

import std.traits;

auto doNothing(T)() if (isDelegate!T) {
  static if (is(ReturnType!T == void)) {
    return delegate(ParameterTypeTuple!T) { };
  }
  else static if (is(ReturnType!T : typeof(null))) {
    return delegate(ParameterTypeTuple!T) { return null; };
  }
  else {
    return delegate(ParameterTypeTuple!T) { return ReturnType!T.init; };
  }
}

unittest {
  alias Action = void delegate();
  Action act = doNothing!Action;
  act();
}

unittest {
  alias Action = int delegate();
  Action act = doNothing!Action;
  assert(act() == 0);
}

unittest {
  alias Action = int delegate(float, string);
  Action act = doNothing!Action;
  assert(act(1.0f, "hi") == 0);
}

unittest {
  alias Action = string delegate();
  Action act = doNothing!Action;
  assert(act() is null);
}
