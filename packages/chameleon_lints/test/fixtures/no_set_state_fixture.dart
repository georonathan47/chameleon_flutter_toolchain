// This fixture exists only to give NoSetState something to analyze.

class FakeState {
  void build() {}

  void badMethod() {
    setState(() {}); // triggers chameleon_no_set_state
  }

  void goodMethod(FakeState other) {
    other.setState(() {}); // has a target — not the flagged pattern
  }

  void setState(void Function() fn) => fn();
}
