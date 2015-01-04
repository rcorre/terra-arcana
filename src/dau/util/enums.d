module dau.util.enums;

import std.conv, std.regex, std.string;

string prettyString(E)(E val) if (is(E == enum)) {
  enum rx = ctRegex!("[A-Z]");
  auto str = val.to!(string).replaceAll(rx, " $&");
  return str[0].toUpper.to!string ~ str[1 .. $];
}

unittest {
  enum Foo {
    oneSingleFoo
  }

  assert(Foo.oneSingleFoo.prettyString == "one Single Foo");
}
