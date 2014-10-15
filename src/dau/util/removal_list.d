module dau.util.removal_list;

import std.container;
import std.algorithm;
import std.range;
import std.container;

/// list that automatically and efficiently removes entries for which cond(entry) is true
class RemovalList(T, alias cond) if (is(typeof(cond(T.init)) == bool)) {
  void insert(T val) {
    head = new Node(val, head);
    if (head.next !is null) {
      head.next.prev = head;
    }
  }

  void clear() {
    head = null;
  }

  Range opSlice() {
    return new Range(head);
  }

  private:
  Node head;

  void removeNode(Node node) {
    assert(node !is null, "attempt to remove null node");
    if (node == head) { // first node
      head = node.next;
    }
    else {
      node.prev.next = node.next;
    }
  }

  class Node {
    T val;
    Node next, prev;

    this(T val, Node next) {
      this.val = val;
      this.next = next;
    }
  }

  class Range {
    Node node;

    this(Node start) {
      node = start;
      stripNodes();
    }

    @property {
      bool empty() { return node is null; }
      T front() { return node.val; }
    }

    void popFront() {
      node = node.next;
      stripNodes();
    }

    /// remove nodes for which cond is true starting from node
    void stripNodes() {
      while(node !is null && cond(node.val)) {
        auto next = node.next;
        removeNode(node);
        node = next;
      }
    }
  }
}

unittest {
  class Foo {
    this(int val, bool active) {
      this.val = val;
      this.active = active;
    }

    bool active;
    int val;
  }

  auto list = new RemovalList!(Foo, x => !x.active);

  list.insert(new Foo(1, false));
  list.insert(new Foo(2, true));
  list.insert(new Foo(3, true));
  list.insert(new Foo(4, false));
  list.insert(new Foo(5, false));

  int[] vals;

  foreach(el ; list) {
    vals ~= el.val;
    if (el.val == 2) { el.active = false; }
  }
  assert(vals == [3,2]);

  list.insert(new Foo(6, true));

  vals = [];
  foreach(el ; list) {
    vals ~= el.val;
    el.active = false;
  }
  assert(vals == [6, 3]);

  foreach(el ; list) { // should never be entered
    assert(0, "vals should be empty");
  }
}
