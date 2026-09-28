// This fixture exists only to give NoPrint something to analyze.

// A user-defined helper that happens to be named debugPrint — not the
// banned Flutter one, so it must not be flagged.
void debugPrint(String message) {}

class FakeLogger {
  void print(String message) {}
}

void bad() {
  // Silences the stock avoid_print lint so only chameleon_no_print is
  // under test here.
  // ignore: avoid_print
  print('hello'); // triggers chameleon_no_print
}

void good(FakeLogger logger) {
  logger.print('hello'); // has a target — not the flagged pattern
  debugPrint('hello'); // resolves to the user-defined function above
}
