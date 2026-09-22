// Reaching into this feature's own internal data/ layer from inside the
// same feature — not flagged.
import 'data/sample_model.dart';

void useSampleModel() {
  const SampleModel(1);
}
