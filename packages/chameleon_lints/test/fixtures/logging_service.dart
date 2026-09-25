// This fixture exists only to prove NoPrint exempts a file named
// logging_service.dart (the logging service's own implementation).

void log() {
  // Silences the stock avoid_print lint so only chameleon_no_print is
  // under test here.
  // ignore: avoid_print
  print('this is the logging service itself'); // must NOT be flagged
}
