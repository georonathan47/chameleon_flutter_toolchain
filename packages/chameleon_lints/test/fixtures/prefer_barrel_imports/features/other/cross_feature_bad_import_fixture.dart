// Reaches past the sample feature's barrel straight into its internal
// data/ layer from a different feature — triggers
// chameleon_prefer_barrel_imports.
import '../sample/data/sample_model.dart';

void useSampleModel() {
  const SampleModel(1);
}
