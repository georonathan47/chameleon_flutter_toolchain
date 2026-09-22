// Imports the sample feature's own barrel file instead of reaching into
// its internal layers — not flagged.
import '../sample/sample.dart';

void useSampleModel() {
  const SampleModel(1);
}
