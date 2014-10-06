module dau.util.removal_list;

import std.container;
import std.algorithm;
import std.range;
import std.container;

// TODO: broken due to handling of popFront on ranges
/// List that supports removal of elements based on a condition while iterating
struct RemovalList(T, alias RemovalCond) {
  private DList!(T) _list;  /// backing store for list

  void insert(T value) {
    _list.insert(value);
  }

  void clear() {
    _list.clear();
  }

  Range opSlice() {
    return Range(_list);
  }

  struct Range {
    this(DList!(T) list) {
      while (!list.empty && RemovalCond(list.front)) {
        list.removeFront();
      }

      _list = list;
      _range = list[];
    }

    @property bool empty() { return _range.empty; }

    /// get the next element in the range
    @property T front() {
      return _range.front();
    }

    /// step to next valid element
    void popFront() {
      _range.popFront();  // pop first element
      // continue to pop and remove elements that have expired
      while (!_range.empty && RemovalCond(_range.front)) {
        _list.linearRemove(take(_range, 1));
        _range.popFront();
      }
    }

    private:
    DList!(T) _list;        /// reference to list of enclosing RemovalList
    DList!(T).Range _range; /// range extracted from backing store
  }
}

unittest {
  import std.stdio;
  import std.string;

  class Test {
    this (string s, bool a) {
      this.s = s;
      this.active = a;
    }

    string s;
    bool active;
  }

  RemovalList!(Test, (t) {return !t.active;}) list;
  list.insert(new Test("a",false)); // test removal from front
  list.insert(new Test("b",false));
  list.insert(new Test("c",true));
  list.insert(new Test("d",true));
  list.insert(new Test("e",true));
  list.insert(new Test("f",true));
  list.insert(new Test("g",false));

  string str;
  foreach (t ; list[]) {
    str ~= t.s;
    if (t.s == "d" || t.s == "e") { t.active = false; }
  }
  assert(str == "cdef");

  str = "";
  foreach (t ; list[]) {
    str ~= t.s;
  }
  assert(str == "cf");
}
