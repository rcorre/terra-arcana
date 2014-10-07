module dau.util.removal_list;

import std.container;
import std.algorithm;
import std.range;
import std.container;

/// list that automatically and efficiently removes entries for which cond(entry) is true
struct RemovalList(T, cond) if (is(typeof(cond(T)) == bool)) {
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

    this(T val, Node next, Node prev) {
      this.val = val;
      this.next = next;
      this.prev = prev;
    }
  }

  struct Range {
    Node node;

    this(Node start) {
      node = start;
      stripNodes();
    }

    @property {
      bool empty() { return node == null; }
      T front() { return node; }
    }

    void popFront() {
      node = node.next;
      stripNodes();
    }

    /// remove nodes for which cond is true starting from node
    void stripNodes() {
      while(node !is null && cond(node)) {
        auto next = node.next;
        removeNode(node);
        node = next;
      }
    }
  }
}
